import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/analytics_viewmodel.dart';

/// Analytics and reports page with real data.
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AnalyticsViewModel>().loadAnalytics(),
          ),
        ],
      ),
      body: Consumer<AnalyticsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          return SingleChildScrollView(
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
                      children: [
                        _MetricCard(
                          title: 'Total Students',
                          value: '${vm.totalStudents}',
                          icon: Icons.school,
                          color: Colors.blue,
                        ),
                        _MetricCard(
                          title: 'Total Teachers',
                          value: '${vm.totalTeachers}',
                          icon: Icons.person,
                          color: Colors.green,
                          subtitle: '${vm.pendingTeachers} pending approval',
                        ),
                        _MetricCard(
                          title: 'Total Lessons',
                          value: '${vm.totalLessons}',
                          icon: Icons.book,
                          color: Colors.orange,
                          subtitle: '${vm.publishedLessons} published',
                        ),
                        _MetricCard(
                          title: 'Total Quizzes',
                          value: '${vm.totalQuizzes}',
                          icon: Icons.quiz,
                          color: Colors.purple,
                        ),
                        _MetricCard(
                          title: 'Avg Progress',
                          value: '${vm.averageProgress.toStringAsFixed(1)}%',
                          icon: Icons.trending_up,
                          color: Colors.teal,
                        ),
                        _MetricCard(
                          title: 'Active Users',
                          value: '${vm.activeUsers}',
                          icon: Icons.people,
                          color: Colors.indigo,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Progress bar visual
                Text(
                  'Average Student Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: vm.averageProgress / 100,
                    minHeight: 20,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vm.averageProgress.toStringAsFixed(1)}% average across all students',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  'Recent Admin Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (vm.recentActivity.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No recent activity',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.recentActivity.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final log = vm.recentActivity[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.history, size: 20),
                          title: Text(
                            log['action'] as String? ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            log['details'] as String? ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            _formatDate(log['created_at'] as String?),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),

                // Quick Reports
                Text(
                  'Quick Reports',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    _ReportCard(
                      icon: Icons.people,
                      title: 'Student Enrollment',
                      description: 'View enrollment data per ALS center',
                    ),
                    _ReportCard(
                      icon: Icons.trending_up,
                      title: 'Learning Progress',
                      description: 'Aggregate student progress report',
                    ),
                    _ReportCard(
                      icon: Icons.quiz,
                      title: 'Quiz Performance',
                      description: 'Pass/fail rates by quiz and subject',
                    ),
                    _ReportCard(
                      icon: Icons.calendar_today,
                      title: 'Session Reports',
                      description: 'Teaching session completion stats',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13)),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
