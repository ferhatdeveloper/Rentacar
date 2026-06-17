import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/locale_provider.dart';
import '../../core/l10n/supported_locales.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    if (compact) {
      return PopupMenuButton<String>(
        tooltip: SupportedLocales.displayName(current.languageCode),
        icon: const Icon(Icons.language, size: 22),
        onSelected: (code) {
          final locale = SupportedLocales.fromCode(code);
          if (locale != null) {
            ref.read(localeProvider.notifier).setLocale(locale);
          }
        },
        itemBuilder: (_) => SupportedLocales.all
            .map(
              (l) => PopupMenuItem(
                value: l.languageCode,
                child: Row(
                  children: [
                    if (l.languageCode == current.languageCode)
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(SupportedLocales.displayName(l.languageCode)),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current.languageCode,
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        items: SupportedLocales.all
            .map(
              (l) => DropdownMenuItem(
                value: l.languageCode,
                child: Text(SupportedLocales.displayName(l.languageCode)),
              ),
            )
            .toList(),
        onChanged: (code) {
          if (code == null) return;
          final locale = SupportedLocales.fromCode(code);
          if (locale != null) {
            ref.read(localeProvider.notifier).setLocale(locale);
          }
        },
      ),
    );
  }
}
