import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tenant_branding.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../presentation/pages/booking_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/vehicles_page.dart';

final publicRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => PublicShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/araclar',
          builder: (context, state) => const VehiclesPage(),
        ),
        GoRoute(
          path: '/rezervasyon',
          builder: (context, state) => const BookingPage(),
        ),
      ],
    ),
  ],
);

class PublicShell extends ConsumerWidget {
  const PublicShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(tenantBrandingProvider);
    return Scaffold(
      body: Column(
        children: [
          _PublicNavBar(branding: branding),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PublicNavBar extends StatelessWidget {
  const _PublicNavBar({required this.branding});

  final TenantBranding branding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 1024;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car_filled, color: branding.accentColor),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    branding.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                  ),
                  if (!isMobile) ...[
                    const Spacer(),
                    _NavLink(label: 'Araçlar', onTap: () => context.go('/araclar')),
                    _NavLink(
                      label: 'Rezervasyon',
                      onTap: () => context.go('/rezervasyon'),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => context.go('/rezervasyon'),
                      child: const Text('Hemen Kirala'),
                    ),
                  ] else ...[
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.go('/rezervasyon'),
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
