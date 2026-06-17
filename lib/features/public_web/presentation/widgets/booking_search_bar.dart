import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';

class BookingSearchBar extends StatefulWidget {
  const BookingSearchBar({super.key});

  @override
  State<BookingSearchBar> createState() => _BookingSearchBarState();
}

class _BookingSearchBarState extends State<BookingSearchBar> {
  String _pickupBranch = 'Merkez Şube';
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 4));

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: isMobile ? _buildMobile() : _buildDesktop(),
      ),
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        Expanded(child: _branchField()),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _dateField('Alış', _pickupDate, _pickDate)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _dateField('İade', _returnDate, _returnPickDate)),
        const SizedBox(width: AppSpacing.lg),
        AppButton(
          label: 'Araç Ara',
          icon: Icons.search,
          onPressed: () => context.go('/araclar'),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        _branchField(),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _dateField('Alış', _pickupDate, _pickDate)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _dateField('İade', _returnDate, _returnPickDate)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Araç Ara',
          icon: Icons.search,
          expand: true,
          onPressed: () => context.go('/araclar'),
        ),
      ],
    );
  }

  Widget _branchField() {
    return DropdownButtonFormField<String>(
      initialValue: _pickupBranch,
      decoration: const InputDecoration(
        labelText: 'Alış Şubesi',
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      items: const [
        DropdownMenuItem(value: 'Merkez Şube', child: Text('Merkez Şube')),
        DropdownMenuItem(value: 'Havalimanı', child: Text('Havalimanı')),
        DropdownMenuItem(value: 'AVM Şubesi', child: Text('AVM Şubesi')),
      ],
      onChanged: (v) => setState(() => _pickupBranch = v!),
    );
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          '${date.day}.${date.month}.${date.year}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        if (!_returnDate.isAfter(_pickupDate)) {
          _returnDate = _pickupDate.add(const Duration(days: 3));
        }
      });
    }
  }

  Future<void> _returnPickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: _pickupDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _returnDate = picked);
  }
}

class TrustBadgesSection extends StatelessWidget {
  const TrustBadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const badges = [
      (Icons.support_agent, '7/24 Destek'),
      (Icons.verified_user, 'Tam Sigortalı'),
      (Icons.cancel_outlined, 'Ücretsiz İptal'),
      (Icons.speed, 'Hızlı Teslim'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            alignment: WrapAlignment.center,
            children: badges
                .map(
                  (b) => _TrustBadge(icon: b.$1, label: b.$2),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.amber, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
