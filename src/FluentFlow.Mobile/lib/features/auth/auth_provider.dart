import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/remote/api_client.dart';

// Estado de autenticação
class AuthState {
  final bool isAuthenticated;
  final String userName;
  final String userId;
  final String userType;
  final bool isLoading;
  final String? error;
  final String? profileImage; // ← novo

  const AuthState({
    this.isAuthenticated = false,
    this.userName = '',
    this.userId = '',
    this.userType = 'Standard',
    this.isLoading = false,
    this.error,
    this.profileImage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? userId,
    String? userType,
    bool? isLoading,
    String? error,
    String? profileImage,
  }) => AuthState(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    userName: userName ?? this.userName,
    userId: userId ?? this.userId,
    userType: userType ?? this.userType,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    profileImage: profileImage ?? this.profileImage,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;
  final ApiClient _api;

  AuthNotifier(this._storage, this._api) : super(const AuthState()) {
    _restoreSession();
  }

  // Restaurar sessão ao arrancar a app
  Future<void> _restoreSession() async {
    final token = await _storage.read(key: StorageKeys.accessToken);
    final userId = await _storage.read(key: StorageKeys.userId);
    final userName = await _storage.read(key: StorageKeys.userName);
    final userType = await _storage.read(key: StorageKeys.userType);

    if (token != null && userId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        userId: userId,
        userName: userName ?? '',
        userType: userType ?? 'Standard',
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _api.login(email, password);
      await _saveSession(result);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        userId: (result['user'] as Map)['id'] as String,
        userName: (result['user'] as Map)['name'] as String,
        userType: (result['user'] as Map)['userType'] as String,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Email ou password incorrectos.',
      );
    }
  }

  // Adicionar ao AuthNotifier:

  Future<void> loginWithTokens(String accessToken, String refreshToken) async {
    // Guardar tokens recebidos do social login
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);

    // Buscar perfil
    try {
      final profile = await _api.getProfile();
      final user = profile['user'] ?? profile;
      await _storage.write(
        key: StorageKeys.userId,
        value: user['id'] as String,
      );
      await _storage.write(
        key: StorageKeys.userName,
        value: user['name'] as String,
      );
      await _storage.write(
        key: StorageKeys.userType,
        value: user['userType'] as String,
      );

      final image = user['profileImageBase64'] as String?;
      if (image != null) {
        await _storage.write(key: StorageKeys.profileImage, value: image);
      }

      state = state.copyWith(
        isAuthenticated: true,
        userId: user['id'] as String,
        userName: user['name'] as String,
        userType: user['userType'] as String,
        profileImage: image,
      );
    } catch (_) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> loadProfile() async {
    try {
      final data = await _api.getProfile();
      final image = data['profileImageBase64'] as String?;
      final name = data['name'] as String? ?? state.userName;

      // ← só actualizar se algo mudou
      if (name == state.userName && image == state.profileImage) return;

      await _storage.write(key: StorageKeys.userName, value: name);
      if (image != null) {
        await _storage.write(key: StorageKeys.profileImage, value: image);
      }

      state = state.copyWith(userName: name, profileImage: image);
    } catch (_) {}
  }

  Future<String?> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? profileImageBase64,
  }) async {
    try {
      await _api.updateProfile(
        name: name,
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
        profileImageBase64: profileImageBase64,
      );

      if (profileImageBase64 != null) {
        await _storage.write(
          key: StorageKeys.profileImage,
          value: profileImageBase64.isEmpty ? '' : profileImageBase64,
        );
      }
      await _storage.write(key: StorageKeys.userName, value: name);

      state = state.copyWith(
        userName: name,
        profileImage: profileImageBase64 ?? state.profileImage,
      );
      return null; // sucesso
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.read(key: StorageKeys.refreshToken);
    if (refresh != null) {
      try {
        await _api.logout(refresh);
      } catch (_) {}
    }
    await _storage.deleteAll();
    state = const AuthState();
  }

  Future<void> _saveSession(Map<String, dynamic> result) async {
    await _storage.write(
      key: StorageKeys.accessToken,
      value: result['accessToken'] as String,
    );
    await _storage.write(
      key: StorageKeys.refreshToken,
      value: result['refreshToken'] as String,
    );
    final user = result['user'] as Map<String, dynamic>;
    await _storage.write(key: StorageKeys.userId, value: user['id'] as String);
    await _storage.write(
      key: StorageKeys.userName,
      value: user['name'] as String,
    );
    await _storage.write(
      key: StorageKeys.userType,
      value: user['userType'] as String,
    );
  }
}

// Providers
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.read(secureStorageProvider)),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.read(secureStorageProvider),
    ref.read(apiClientProvider),
  ),
);
