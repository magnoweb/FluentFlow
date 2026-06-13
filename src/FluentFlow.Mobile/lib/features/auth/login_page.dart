import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../l10n/app_localizations.dart';
import 'auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController()..text = "admin@fluentflow.com";
  final _passwordCtrl = TextEditingController()..text = "Qawsed@12";
  bool _obscure = true;
  bool _socialLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.isAuthenticated) context.go('/');
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF594AE2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Fluent',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            TextSpan(
                              text: 'Flow',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF594AE2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Text(
                    l10n.authWelcomeBack,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.authLoginSubtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Email
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.authEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: l10n.authPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),

                  // Erro
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.error == 'invalid_credentials'
                                  ? l10n.authInvalidCredentials
                                  : auth.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Botão login
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.isLoading ? null : _login,
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.authSignIn),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divisor
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          l10n.commonOr,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _socialLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.g_mobiledata,
                              size: 24,
                              color: Color(0xFFEA4335),
                            ),
                      label: Text(l10n.authContinueGoogle),
                      onPressed: _socialLoading
                          ? null
                          : () => _socialLogin('Google'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Microsoft
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _socialLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.window,
                              size: 24,
                              color: Color(0xFFEA4335),
                            ),
                      label: Text(l10n.authContinueMicrosoft),
                      onPressed: _socialLoading
                          ? null
                          : () => _socialLogin('Microsoft'),
                    ),
                  ),

                  // const SizedBox(height: 10),

                  // // GitHub
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: OutlinedButton.icon(
                  //     icon: const Icon(
                  //       Icons.code,
                  //       size: 20,
                  //       color: Color(0xFF24292F),
                  //     ),
                  //     label: Text(l10n.authContinueGitHub),
                  //     onPressed: _socialLoading
                  //         ? null
                  //         : () => _socialLogin('GitHub'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;
    await ref.read(authProvider.notifier).login(email, password);
  }

  Future<void> _socialLogin(String provider) async {
    setState(() => _socialLoading = true);
    try {
      // URL da API com callback para o scheme da app
      final apiBase = ApiConstants.baseUrl;
      final returnUrl = Uri.encodeComponent(
        'fluentflow://auth/social-callback',
      );
      final loginUrl = '$apiBase/api/auth/login/$provider?returnUrl=$returnUrl';

      // Abrir browser externo e aguardar o callback
      final result = await FlutterWebAuth2.authenticate(
        url: loginUrl,
        callbackUrlScheme: 'fluentflow',
      );

      // result = "fluentflow://auth/callback?accessToken=...&refreshToken=..."
      // Processar tokens directamente aqui (sem navegar para outra página)
      final uri = Uri.parse(result);
      final params = uri.queryParameters;

      final error = params['error'];
      if (error != null && error.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(Uri.decodeComponent(error))));
        }
        return;
      }

      final accessToken = params['accessToken'];
      final refreshToken = params['refreshToken'];

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        await ref
            .read(authProvider.notifier)
            .loginWithTokens(accessToken, refreshToken);
        // O redirect é tratado pelo listener do authProvider
      }
    } catch (e) {
      // Utilizador cancelou o browser — não mostrar erro
      if (e.toString().contains('CANCELED') ||
          e.toString().contains('canceled'))
        return;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro no login social: $e')));
      }
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }
}
