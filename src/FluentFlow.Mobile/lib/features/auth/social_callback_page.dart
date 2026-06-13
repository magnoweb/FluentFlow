import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_provider.dart';

class SocialCallbackPage extends ConsumerStatefulWidget {
  /// URI completo recebido pelo deep link — ex:
  /// fluentflow://auth/callback?accessToken=...&refreshToken=...
  final String callbackUri;

  const SocialCallbackPage({super.key, required this.callbackUri});

  @override
  ConsumerState<SocialCallbackPage> createState() => _SocialCallbackPageState();
}

class _SocialCallbackPageState extends ConsumerState<SocialCallbackPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _handleCallback(l10n);
      }
    });
  }

  Future<void> _handleCallback(AppLocalizations l10n) async {
    try {
      final uri = Uri.parse(widget.callbackUri);
      final params = uri.queryParameters;

      final error = params['error'];
      if (error != null && error.isNotEmpty) {
        setState(() => _error = Uri.decodeComponent(error));
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) context.go('/login');
        return;
      }

      final accessToken = params['accessToken'];
      final refreshToken = params['refreshToken'];

      if (accessToken == null  || accessToken.isEmpty ||
          refreshToken == null || refreshToken.isEmpty) {
        setState(() => _error = l10n.socialCallbackTokensNotReceived);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) context.go('/login');
        return;
      }

      // Guardar tokens e autenticar
      await ref.read(authProvider.notifier).loginWithTokens(accessToken, refreshToken);

      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = l10n.socialCallbackError2(e.toString()));
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF594AE2),
      body: SafeArea(
        child: Center(
          child: _error != null ? _buildError(l10n) : _buildLoading(l10n),
        ),
      ),
    );
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text('F',
                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.socialCallbackAuthenticating,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
        SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 56),
          const SizedBox(height: 16),
          Text(l10n.socialCallbackError,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          const SizedBox(height: 24),
          Text(l10n.socialCallbackRedirecting,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
}