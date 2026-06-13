import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/language_service.dart';

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white),
      tooltip: 'Idioma / Language',
      onSelected: (code) => ref.read(localeProvider.notifier).setLocale(code),
      itemBuilder: (_) => LanguageService.supported.map((lang) {
        final isSelected = lang.$1 == current;
        return PopupMenuItem<String>(
          value: lang.$1,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: isSelected ? const Color(0xFF594AE2) : Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(
                lang.$2,
                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
