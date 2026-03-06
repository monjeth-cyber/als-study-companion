import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../teacher/views/teacher_dashboard_view.dart';

/// Shown to teachers whose account is not yet approved by an admin.
/// Polls the server periodically and auto-navigates when approved.
class TeacherPendingApprovalView extends StatefulWidget {
  const TeacherPendingApprovalView({super.key});

  @override
  State<TeacherPendingApprovalView> createState() =>
      _TeacherPendingApprovalViewState();
}

class _TeacherPendingApprovalViewState
    extends State<TeacherPendingApprovalView> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkApproval(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkApproval() async {
    final authVm = context.read<AuthViewModel>();
    // Reload user from DB to get latest teacher_verified flag
    await authVm.checkEmailVerified(); // also refreshes user
    if (!mounted) return;

    if (!authVm.needsTeacherApproval) {
      _pollTimer?.cancel();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TeacherDashboardView()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Awaiting Admin Approval',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your teacher account is pending approval.\n'
                  'An administrator will review your registration shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Checking approval status…',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () async {
                    _pollTimer?.cancel();
                    final nav = Navigator.of(context);
                    await authVm.signOut();
                    if (!context.mounted) return;
                    nav.popUntil((route) => route.isFirst);
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
