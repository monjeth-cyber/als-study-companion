import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/shared_core.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../student/views/student_dashboard_view.dart';
import '../../teacher/views/teacher_dashboard_view.dart';
import 'biometric_setup_view.dart';

/// Waiting screen shown after registration — polls Firebase to check if
/// the user has verified their email. Offers a resend button.
class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  Timer? _pollTimer;
  bool _checking = false;
  bool _resendCooldown = false;

  @override
  void initState() {
    super.initState();
    // Poll every 3 seconds for email verification
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkVerification(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    if (_checking) return;
    _checking = true;

    final authVm = context.read<AuthViewModel>();
    final verified = await authVm.checkEmailVerified();

    _checking = false;
    if (!mounted) return;

    if (verified) {
      _pollTimer?.cancel();
      _navigateToDashboard(authVm.currentRole ?? UserRole.student);
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;

    setState(() => _resendCooldown = true);

    final authVm = context.read<AuthViewModel>();
    await authVm.sendEmailVerification();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email resent!')));

    // 30-second cooldown before allowing another resend
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _resendCooldown = false);
    });
  }

  void _navigateToDashboard(UserRole role) {
    // If the device supports biometrics and the user has NOT yet enabled
    // biometric login, offer the setup step before going to the dashboard.
    final authVm = context.read<AuthViewModel>();
    if (authVm.isBiometricAvailable && !authVm.isBiometricEnabled) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BiometricSetupView()),
        (_) => false,
      );
      return;
    }

    Widget dashboard;
    switch (role) {
      case UserRole.student:
        dashboard = const StudentDashboardView();
        break;
      case UserRole.teacher:
        dashboard = const TeacherDashboardView();
        break;
      case UserRole.admin:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin access is via the web panel.')),
        );
        return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => dashboard),
      (_) => false,
    );
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
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify your email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to\n${authVm.currentUser?.email ?? ''}',
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
                  'Waiting for verification…',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _resendCooldown ? null : _resendEmail,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(
                    _resendCooldown
                        ? 'Resend (wait 30s)'
                        : 'Resend Verification Email',
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    _pollTimer?.cancel();
                    final nav = Navigator.of(context);
                    await authVm.signOut();
                    if (!mounted) return;
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
