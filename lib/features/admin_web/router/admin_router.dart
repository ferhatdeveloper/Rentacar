import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_spacing.dart';
import '../presentation/pages/admin_dashboard_page.dart';
import '../presentation/pages/admin_fleet_page.dart';
import '../presentation/pages/admin_rentals_page.dart';
import '../presentation/pages/website_settings_page.dart';

final adminRouter = GoRouter(
  initialLocation: '/admin',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/fleet',
          builder: (context, state) => const AdminFleetPage(),
        ),
        GoRoute(
          path: '/admin/rentals',
          builder: (context, state) => const AdminRentalsPage(),
        ),
        GoRoute(
          path: '/admin/website',
          builder: (context, state) => const WebsiteSettingsPage(),
        ),
      ],
    ),
  ],
);

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _navItems = [
    (Icons.dashboard_outlined, 'Dashboard', '/admin'),
    (Icons.calendar_month_outlined, 'Rezervasyonlar', '/admin/rentals'),
    (Icons.directions_car_outlined, 'Filo', '/admin/fleet'),
    (Icons.people_outline, 'Müşteriler', '/admin'),
    (Icons.payments_outlined, 'Ödemeler', '/admin'),
    (Icons.bar_chart_outlined, 'Raporlar', '/admin'),
    (Icons.language, 'Web Sitesi', '/admin/website'),
    (Icons.settings_outlined, 'Ayarlar', '/admin'),
  ];

  int _indexForLocation(String location) {
    final index = _navItems.indexWhere((item) => location.startsWith(item.$3));
    if (index == -1) return 0;
    // /admin exact match should beat partial matches
    if (location == '/admin') return 0;
    if (location.startsWith('/admin/rentals')) return 1;
    if (location.startsWith('/admin/fleet')) return 2;
    if (location.startsWith('/admin/website')) return 6;
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showSidebar = width >= 900;
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexForLocation(location);

    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          if (showSidebar) _Sidebar(
            items: _navItems,
            selectedIndex: selectedIndex,
            onSelect: (index) => context.go(_navItems[index].$3),
          ),
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(showMenu: !showSidebar, scaffoldKey: _scaffoldKey),
                Expanded(child: widget.child),
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
  const _AdminTopBar({required this.showMenu, required this.scaffoldKey});

  final bool showMenu;
  final GlobalKey<ScaffoldState> scaffoldKey;

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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.amber,
            child: Text('A', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
