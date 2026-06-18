import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/pages/admin_login_page.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../shared/widgets/language_buttons.dart';
import '../presentation/pages/admin_checkin_page.dart';
import '../presentation/pages/admin_customers_page.dart';
import '../presentation/pages/admin_dashboard_page.dart';
import '../presentation/pages/admin_fleet_page.dart';
import '../presentation/pages/admin_invoices_page.dart';
import '../presentation/pages/admin_payments_page.dart';
import '../presentation/pages/admin_rentals_page.dart';
import '../presentation/pages/admin_reports_page.dart';
import '../presentation/pages/admin_settings_page.dart';
import '../presentation/pages/admin_maintenance_page.dart';
import '../presentation/pages/website_settings_page.dart';

final _adminRootNavigatorKey = GlobalKey<NavigatorState>();

final adminRouter = GoRouter(
  navigatorKey: _adminRootNavigatorKey,
  initialLocation: '/admin',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final auth = container.read(authNotifierProvider);
    if (auth.isLoading) return null;

    final isLogin = state.matchedLocation == '/admin/login';
    final isLoggedIn = auth.valueOrNull != null;

    if (!isLoggedIn && !isLogin) return '/admin/login';
    if (isLoggedIn && isLogin) return '/admin';
    return null;
  },
  routes: [
    GoRoute(
      path: '/admin/login',
      builder: (context, state) => const AdminLoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/rentals',
          builder: (context, state) => const AdminRentalsPage(),
        ),
        GoRoute(
          path: '/admin/fleet',
          builder: (context, state) => const AdminFleetPage(),
        ),
        GoRoute(
          path: '/admin/customers',
          builder: (context, state) => const AdminCustomersPage(),
        ),
        GoRoute(
          path: '/admin/payments',
          builder: (context, state) => const AdminPaymentsPage(),
        ),
        GoRoute(
          path: '/admin/reports',
          builder: (context, state) => const AdminReportsPage(),
        ),
        GoRoute(
          path: '/admin/maintenance',
          builder: (context, state) => const AdminMaintenancePage(),
        ),
        GoRoute(
          path: '/admin/invoices',
          builder: (context, state) => const AdminInvoicesPage(),
        ),
        GoRoute(
          path: '/admin/website',
          builder: (context, state) => const WebsiteSettingsPage(),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (context, state) => const AdminSettingsPage(),
        ),
        GoRoute(
          path: '/admin/checkin/:rentalId',
          builder: (context, state) => AdminCheckInPage(
            rentalId: state.pathParameters['rentalId']!,
            mode: state.uri.queryParameters['mode'] ?? 'pickup',
          ),
        ),
      ],
    ),
  ],
);

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _navItems = [
    (Icons.dashboard_outlined, 'Dashboard', '/admin'),
    (Icons.calendar_month_outlined, 'Rezervasyonlar', '/admin/rentals'),
    (Icons.directions_car_outlined, 'Filo', '/admin/fleet'),
    (Icons.people_outline, 'Müşteriler', '/admin/customers'),
    (Icons.payments_outlined, 'Ödemeler', '/admin/payments'),
    (Icons.bar_chart_outlined, 'Raporlar', '/admin/reports'),
    (Icons.build_outlined, 'Bakım', '/admin/maintenance'),
    (Icons.receipt_long, 'Faturalar', '/admin/invoices'),
    (Icons.language, 'Web Sitesi', '/admin/website'),
    (Icons.settings_outlined, 'Ayarlar', '/admin/settings'),
  ];

  int _indexForLocation(String location) {
    if (location.startsWith('/admin/rentals') || location.startsWith('/admin/checkin')) {
      return 1;
    }
    if (location.startsWith('/admin/fleet')) return 2;
    if (location.startsWith('/admin/customers')) return 3;
    if (location.startsWith('/admin/payments')) return 4;
    if (location.startsWith('/admin/reports')) return 5;
    if (location.startsWith('/admin/maintenance')) return 6;
    if (location.startsWith('/admin/invoices')) return 7;
    if (location.startsWith('/admin/website')) return 8;
    if (location.startsWith('/admin/settings')) return 9;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final showSidebar = width >= 900;
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexForLocation(location);
    final authUser = ref.watch(authNotifierProvider).valueOrNull;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      body: Row(
        children: [
          if (showSidebar)
            _Sidebar(
              items: _navItems,
              selectedIndex: selectedIndex,
              onSelect: (index) => context.go(_navItems[index].$3),
            ),
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(
                  showMenu: !showSidebar,
                  scaffoldKey: scaffoldKey,
                  userName: authUser?.fullName ?? 'Admin',
                  onLogout: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go('/admin/login');
                  },
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: showSidebar
          ? null
          : Drawer(
              child: _Sidebar(
                items: _navItems,
                selectedIndex: selectedIndex,
                onSelect: (index) {
                  Navigator.pop(context);
                  context.go(_navItems[index].$3);
                },
              ),
            ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<(IconData, String, String)> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.directions_car_filled, color: AppColors.amber),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Rentacar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = index == selectedIndex;
                return ListTile(
                  leading: Icon(
                    item.$1,
                    color: selected ? AppColors.amber : Colors.white60,
                  ),
                  title: Text(
                    item.$2,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: selected,
                  selectedTileColor: Colors.white.withValues(alpha: 0.08),
                  onTap: () => onSelect(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.showMenu,
    required this.scaffoldKey,
    required this.userName,
    required this.onLogout,
  });

  final bool showMenu;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
          const Spacer(),
          const LanguageButtons(),
          const SizedBox(width: AppSpacing.md),
          Text(userName, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.amber,
              child: Text(
                userName.isNotEmpty ? userName[0] : 'A',
                style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700),
              ),
            ),
            onSelected: (v) {
              if (v == 'logout') onLogout();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'logout', child: Text('Çıkış Yap')),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
