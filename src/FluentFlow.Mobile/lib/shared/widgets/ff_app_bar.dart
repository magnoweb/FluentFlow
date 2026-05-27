import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FFAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const FFAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF594AE2),
      foregroundColor: Colors.white,
      elevation: 1,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  onBack ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
            )
          : null,
      actions: actions,
    );
  }
}
