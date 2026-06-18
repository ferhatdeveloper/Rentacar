import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/l10n/supported_locales.dart';

/// Görünür dil değiştirme butonları (AR / TR / EN / KU) — segmented kontrol.
///
/// Seçili dile dokununca [localeProvider] güncellenir; Arapça ve Kürtçe (ckb)
/// için uygulama otomatik olarak RTL düzene geçer.
class LanguageButtons extends ConsumerWidget {
  const LanguageButtons({super.key, this.onDark = false});

  /// Koyu zemin (ör. lacivert) üzerinde kullanılırken kontrast için.
  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final borderColor =
        onDark ? Colors.white24 : Colors.black.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final locale in SupportedLocales.all)
            _LanguagePill(
              label: SupportedLocales.shortLabel(locale.languageCode),
              tooltip: SupportedLocales.displayName(locale.languageCode),
              selected: locale.languageCode == current.languageCode,
              onDark: onDark,
              onTap: () => ref.read(localeProvider.notifier).setLocale(locale),
            ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onDark,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    if (selected) {
      fg = AppColors.navy;
    } else {
      fg = onDark ? Colors.white70 : AppColors.textSecondary;
    }

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: selected,
        label: tooltip,
        child: Material(
          color: selected ? AppColors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
