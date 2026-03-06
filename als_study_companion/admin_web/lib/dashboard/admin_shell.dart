import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import '../users/user_management_page.dart';
import '../analytics/analytics_page.dart';
import '../centers/center_management_page.dart';
import 'content_management_page.dart';

/// Admin web panel shell with sidebar navigation.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.people, label: 'Users'),
    _NavItem(icon: Icons.library_books, label: 'Content'),
    _NavItem(icon: Icons.location_city, label: 'ALS Centers'),
    _NavItem(icon: Icons.analytics, label: 'Analytics'),
  ];

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    UserManagementPage(),
    ContentManagementPage(),
    CenterManagementPage(),
    AnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(
                    Icons.school,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  if (MediaQuery.of(context).size.width > 1200)
                    const Text(
                      'ALS Admin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            destinations: _navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // Main content area
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
