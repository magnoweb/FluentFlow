import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/errors/app_exception.dart';
import '../../core/constants/storage_keys.dart';
import '../remote/api_client.dart';
import '../dto/auth_dto.dart';

class AuthRepository {
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<AuthResultDto> login(String email, String password) async {
    try {
      final data = await _api.login(email, password);
      final result = AuthResultDto.fromJson(data);
      await _persist(result);
      return result;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Erro ao fazer login: $e');
    }
  }

  Future<AuthResultDto> refresh() async {
    final token = await _storage.read(key: StorageKeys.refreshToken);
    if (token == null) throw const UnauthorizedException();
    final data = await _api.refresh(token);
    final result = AuthResultDto.fromJson(data);
    await _persist(result);
    return result;
  }

  Future<void> logout() async {
    final token = await _storage.read(key: StorageKeys.refreshToken);
    if (token != null) {
      try {
        await _api.logout(token);
      } catch (_) {}
    }
    await _storage.deleteAll();
  }

  Future<bool> isAuthenticated() async =>
      await _storage.read(key: StorageKeys.accessToken) != null;

  Future<void> _persist(AuthResultDto r) async {
    await _storage.write(key: StorageKeys.accessToken, value: r.accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: r.refreshToken);
    await _storage.write(key: StorageKeys.userId, value: r.user.id);
    await _storage.write(key: StorageKeys.userName, value: r.user.name);
    await _storage.write(key: StorageKeys.userType, value: r.user.userType);
  }
}
