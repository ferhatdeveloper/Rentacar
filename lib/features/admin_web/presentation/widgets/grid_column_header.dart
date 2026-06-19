import 'package:flutter/material.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';

/// DevExpress benzeri tablo başlığı: tıklayınca sıralar, huni ikonuyla açılan
/// dropdown'da sütunun benzersiz değerlerini onay kutularıyla filtreler.
class GridColumnHeader extends StatelessWidget {
  const GridColumnHeader({
    super.key,
    required this.title,
    required this.columnIndex,
    required this.activeSortIndex,
    required this.ascending,
    required this.onSort,
    required this.distinctValues,
    required this.selected,
    required this.onApply,
  });

  final String title;
  final int columnIndex;
  final int? activeSortIndex;
  final bool ascending;
  final void Function(int columnIndex) onSort;
  final List<String> distinctValues;
  final Set<String> selected;
  final void Function(Set<String>) onApply;

  @override
  Widget build(BuildContext context) {
    final isSorted = activeSortIndex == columnIndex;
    final hasFilter = selected.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            onTap: () => onSort(columnIndex),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
                  if (isSorted) ...[
                    const SizedBox(width: 2),
                    Icon(
                      ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 13,
                      color: AppColors.navy,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        _FilterButton(
          title: title,
          distinctValues: distinctValues,
          selected: selected,
          hasFilter: hasFilter,
          onApply: onApply,
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.title,
    required this.distinctValues,
    required this.selected,
    required this.hasFilter,
    required this.onApply,
  });

  final String title;
  final List<String> distinctValues;
  final Set<String> selected;
  final bool hasFilter;
  final void Function(Set<String>) onApply;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Filtrele',
      position: PopupMenuPosition.under,
      icon: Icon(
        hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
        size: 16,
        color: hasFilter ? AppColors.amber : AppColors.textSecondary,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _FilterPanel(
            title: title,
            distinctValues: distinctValues,
            selected: selected,
            onApply: onApply,
          ),
        ),
      ],
    );
  }
}

class _FilterPanel extends StatefulWidget {
  const _FilterPanel({
    required this.title,
    required this.distinctValues,
    required this.selected,
    required this.onApply,
  });

  final String title;
  final List<String> distinctValues;
  final Set<String> selected;
  final void Function(Set<String>) onApply;

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late final Set<String> _temp = {...widget.selected};
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final values = widget.distinctValues
        .where((v) => _search.isEmpty || v.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    final allChecked = _temp.isEmpty || _temp.length == widget.distinctValues.length;

    return SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Ara...',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
          ),
          CheckboxListTile(
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            value: allChecked,
            title: const Text('(Tümü)', style: TextStyle(fontWeight: FontWeight.w600)),
            onChanged: (v) => setState(() => _temp.clear()),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final v in values)
                    CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      value: _temp.contains(v),
                      title: Text(v, overflow: TextOverflow.ellipsis),
                      onChanged: (checked) => setState(() {
                        if (checked == true) {
                          _temp.add(v);
                        } else {
                          _temp.remove(v);
                        }
                      }),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onApply(<String>{});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Temizle'),
                ),
                FilledButton(
                  onPressed: () {
                    widget.onApply({..._temp});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Uygula'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
