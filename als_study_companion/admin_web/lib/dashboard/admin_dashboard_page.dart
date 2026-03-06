import 'package:flutter/material.dart';

/// Admin dashboard overview page with summary cards.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.0,
                  children: const [
                    _DashboardCard(
                      title: 'Total Students',
                      value: '0',
                      icon: Icons.school,
                      color: Colors.blue,
                    ),
                    _DashboardCard(
                      title: 'Total Teachers',
                      value: '0',
                      icon: Icons.person,
                      color: Colors.green,
                    ),
                    _DashboardCard(
                      title: 'Total Lessons',
                      value: '0',
                      icon: Icons.book,
                      color: Colors.orange,
                    ),
                    _DashboardCard(
                      title: 'ALS Centers',
                      value: '0',
                      icon: Icons.location_city,
                      color: Colors.purple,
                    ),
                    _DashboardCard(
                      title: 'Active Users',
                      value: '0',
                      icon: Icons.people,
                      color: Colors.teal,
                    ),
                    _DashboardCard(
                      title: 'Avg Progress',
                      value: '0%',
                      icon: Icons.trending_up,
                      color: Colors.indigo,
                    ),
                    _DashboardCard(
                      title: 'Total Quizzes',
                      value: '0',
                      icon: Icons.quiz,
                      color: Colors.red,
                    ),
                    _DashboardCard(
                      title: 'Announcements',
                      value: '0',
                      icon: Icons.campaign,
                      color: Colors.amber,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Activity Section
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No recent activity recorded.\nConnect Firebase to see live data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(title, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
