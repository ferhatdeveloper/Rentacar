import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../features/fleet/domain/entities/vehicle.dart';
import '../../../../features/fleet/presentation/providers/fleet_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_vehicle_card.dart';
import '../widgets/booking_search_bar.dart';
import '../widgets/public_footer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(tenantBrandingProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          _HeroSection(branding: branding, isMobile: isMobile),
          const SizedBox(height: AppSpacing.xxxl),
          _PopularVehiclesSection(isMobile: isMobile),
          const SizedBox(height: AppSpacing.xxxl),
          const TrustBadgesSection(),
          const SizedBox(height: AppSpacing.xxxl),
          PublicFooter(branding: branding),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.branding, required this.isMobile});

  final dynamic branding;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? AppSpacing.md : AppSpacing.xl,
                AppSpacing.xxxl,
                isMobile ? AppSpacing.md : AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.heroTitle,
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.heroSubtitle,
                    style: GoogleFonts.sourceSans3(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                  const SizedBox(height: AppSpacing.xl),
                  const BookingSearchBar()
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(begin: 0.08, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularVehiclesSection extends ConsumerWidget {
  const _PopularVehiclesSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(availableVehiclesProvider);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.homePopularVehicles,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/araclar'),
                    child: Text(l10n.homeSeeAll),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              vehiclesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => AppEmptyState(
                  title: l10n.homeVehiclesLoadError,
                  onRetry: () => ref.invalidate(availableVehiclesProvider),
                ),
                data: (vehicles) => _VehicleGrid(
                  vehicles: vehicles.take(4).toList(),
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleGrid extends StatelessWidget {
  const _VehicleGrid({required this.vehicles, required this.isMobile});

  final List<Vehicle> vehicles;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: vehicles
            .map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppVehicleCard(
                  vehicle: v,
                  compact: true,
                  onTap: () => context.go('/rezervasyon'),
                ),
              ),
            )
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 0.72,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return AppVehicleCard(
          vehicle: vehicle,
          onTap: () => context.go('/rezervasyon'),
        );
      },
    );
  }
}
