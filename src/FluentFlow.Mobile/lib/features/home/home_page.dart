import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_provider.dart';
import 'home_provider.dart';
import '../../shared/widgets/ff_loading.dart';
import '../../shared/widgets/offline_banner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isOnline = true;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    // Carregar perfil apenas uma vez, após o primeiro frame
    if (!_profileLoaded) {
      _profileLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).loadProfile();
      });
    }
  }

  Future<void> _checkConnectivity() async {
    final r = await Connectivity().checkConnectivity();
    setState(() => _isOnline = r.any((c) => c != ConnectivityResult.none));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final summary = ref.watch(homeSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FluentFlow'),
        backgroundColor: const Color(0xFF594AE2),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // Avatar + menu
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              onSelected: (v) => _handleMenu(context, v, auth),
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        auth.userType,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('O meu perfil'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: 'sessions',
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('Sessões'),
                    onTap: () => context.go('/sessions'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Sobre'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Sair', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
              child: _Avatar(auth: auth),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isOnline) const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(homeSummaryProvider.future),
              child: summary.when(
                loading: () => const FFLoading(),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (s) => _buildContent(context, auth, s),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenu(BuildContext ctx, String value, AuthState auth) {
    switch (value) {
      case 'profile':
        _showProfileSheet(ctx, auth);
      case 'about':
        _showAbout(ctx);
      case 'logout':
        ref.read(authProvider.notifier).logout();
    }
  }

  // ── Profile bottom sheet ────────────────────────────────────────────────────
  void _showProfileSheet(BuildContext ctx, AuthState auth) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProfileSheet(auth: auth),
    );
  }

  // ── Sobre ──────────────────────────────────────────────────────────────────
  Future<void> _showAbout(BuildContext ctx) async {
    final info = await PackageInfo.fromPlatform();
    if (!ctx.mounted) return;

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF594AE2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'F',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('FluentFlow'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão ${info.version} (${info.buildNumber})',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'FluentFlow é uma plataforma de estudo por repetição '
              'espaçada com foco em listening e speaking.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para adicionar, editar ou remover cards e '
                      'decks, utilize a versão Web do FluentFlow.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthState auth,
    HomeSummary summary,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Olá, ${auth.userName.split(' ').first}!',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            _StatCard(label: 'Decks', value: '${summary.decks.length}'),
            const SizedBox(width: 8),
            _StatCard(
              label: 'Para hoje',
              value: '${summary.totalDueToday}',
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _StatCard(
              label: 'Estudadas',
              value: '${summary.studiedToday}',
              color: Colors.green,
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (summary.decks.isEmpty)
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.library_books_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ainda não tens decks.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cria um deck na versão Web e sincroniza aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        else ...[
          Text(
            'Os meus decks',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...summary.decks.take(5).map((deck) {
            final dash = summary.dashboards[deck.id];
            return _DeckCard(
              deck: deck,
              dashboard: dash,
              onStudy: () => context.go('/study/${deck.id}/plan'),
              onDetail: () => context.go('/decks/${deck.id}'),
            );
          }),
          if (summary.decks.length > 5) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/decks'),
              child: Text('Ver todos (${summary.decks.length})'),
            ),
          ],
        ],
      ],
    );
  }
}

// ── Avatar widget ─────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final AuthState auth;
  const _Avatar({required this.auth});

  @override
  Widget build(BuildContext context) {
    if (auth.profileImage != null && auth.profileImage!.isNotEmpty) {
      try {
        final bytes = base64Decode(
          auth.profileImage!.replaceAll(
            RegExp(r'data:image/[^;]+;base64,'),
            '',
          ),
        );
        return CircleAvatar(radius: 18, backgroundImage: MemoryImage(bytes));
      } catch (_) {}
    }
    // Iniciais
    final initials = auth.userName
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white24,
      child: Text(
        initials.isEmpty ? 'U' : initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ── Profile bottom sheet ──────────────────────────────────────────────────────
class ProfileSheet extends ConsumerStatefulWidget {
  final AuthState auth;
  const ProfileSheet({super.key, required this.auth});

  @override
  ConsumerState<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<ProfileSheet> {
  late final _nameCtrl = TextEditingController(text: widget.auth.userName);
  late final _emailCtrl = TextEditingController();
  final _currPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  bool _saving = false;
  String? _error;
  String? _avatarBase64;
  bool _removeAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _avatarBase64 = widget.auth.profileImage;
  }

  Future<void> _loadEmail() async {
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.getProfile();
      _emailCtrl.text = data['email'] as String? ?? '';
      setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    // Verificar tamanho — max 200KB
    if (bytes.length > 200 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem demasiado grande. Máximo 200 KB.'),
          ),
        );
      }
      return;
    }
    setState(() {
      _avatarBase64 = base64Encode(bytes);
      _removeAvatar = false;
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final error = await ref
        .read(authProvider.notifier)
        .updateProfile(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          currentPassword: _currPwCtrl.text.isEmpty ? null : _currPwCtrl.text,
          newPassword: _newPwCtrl.text.isEmpty ? null : _newPwCtrl.text,
          profileImageBase64: _removeAvatar ? '' : _avatarBase64,
        );

    setState(() => _saving = false);

    if (error == null) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = !_removeAvatar && _avatarBase64 != null && _avatarBase64!.isNotEmpty;

    // viewInsets.bottom = teclado aberto
    // viewPadding.bottom = altura da nav bar
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 20; // padding extra
    
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'O meu perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF594AE2).withOpacity(0.1),
                  backgroundImage: hasAvatar
                      ? MemoryImage(
                          base64Decode(
                            _avatarBase64!.replaceAll(
                              RegExp(r'data:image/[^;]+;base64,'),
                              '',
                            ),
                          ),
                        )
                      : null,
                  child: hasAvatar
                      ? null
                      : Text(
                          widget.auth.userName.isNotEmpty
                              ? widget.auth.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF594AE2),
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF594AE2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (hasAvatar) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: Colors.red,
                ),
                label: const Text(
                  'Remover foto',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                onPressed: () => setState(() {
                  _removeAvatar = true;
                  _avatarBase64 = null;
                }),
              ),
            ],

            const SizedBox(height: 16),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Alterar password',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currPwCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password actual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPwCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova password',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat e Deck cards (reutilizados da versão anterior) ───────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    this.color = const Color(0xFF594AE2),
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    ),
  );
}

class _DeckCard extends StatelessWidget {
  final dynamic deck, dashboard;
  final VoidCallback onStudy, onDetail;
  const _DeckCard({
    required this.deck,
    required this.dashboard,
    required this.onStudy,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final due = dashboard?.dueToday ?? 0;
    final nw = dashboard?.newToday ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deck.language.toUpperCase()} · '
                      '${dashboard?.totalCards ?? 0} cards',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (due > 0 || nw > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$due revisão · $nw novas',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (due > 0 || nw > 0)
                FilledButton(
                  onPressed: onStudy,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Estudar', style: TextStyle(fontSize: 13)),
                )
              else
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
