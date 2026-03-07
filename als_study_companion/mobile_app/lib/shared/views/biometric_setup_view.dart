import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/shared_core.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../student/views/student_dashboard_view.dart';
import '../../teacher/views/teacher_dashboard_view.dart';

/// Shown immediately after a successful email verification.
///
/// Gives students and teachers the option to register their Fingerprint or
/// Face ID so future logins can use biometric auto-fill instead of typing
/// credentials.  Users who skip this step can enable it later from their
/// profile settings.
class BiometricSetupView extends StatefulWidget {
  const BiometricSetupView({super.key});

  @override
  State<BiometricSetupView> createState() => _BiometricSetupViewState();
}

class _BiometricSetupViewState extends State<BiometricSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isEnabling = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _handleEnable() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isEnabling = true);

    final authVm = context.read<AuthViewModel>();
    final email = authVm.currentUser?.email ?? '';

    final success = await authVm.setupBiometric(
      email: email,
      password: _passwordCtrl.text,
    );

    setState(() => _isEnabling = false);

    if (!mounted) return;

    if (success) {
      _showSuccess('${authVm.biometricLabel} login enabled!');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _navigateToDashboard(authVm.currentRole ?? UserRole.student);
    } else {
      _showError(
        'Biometric authentication was not completed. You can enable it later from your profile.',
      );
    }
  }

  void _skip() {
    final authVm = context.read<AuthViewModel>();
    _navigateToDashboard(authVm.currentRole ?? UserRole.student);
  }

  void _navigateToDashboard(UserRole role) {
    Widget dashboard;
    switch (role) {
      case UserRole.student:
        dashboard = const StudentDashboardView();
        break;
      case UserRole.teacher:
        dashboard = const TeacherDashboardView();
        break;
      case UserRole.admin:
        // Admin uses the web panel — fall back to login
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => dashboard),
      (_) => false,
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final biometricLabel = authVm.biometricLabel;
    final email = authVm.currentUser?.email ?? '';

    // Choose icon based on biometric type
    final biometricIcon =
        biometricLabel == 'Face ID'
            ? Icons.face_outlined
            : Icons.fingerprint;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon ────────────────────────────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    biometricIcon,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Headline ─────────────────────────────────────────────────
                Text(
                  'Enable $biometricLabel Login',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Skip typing your password every time.\n'
                  'Confirm your credentials once, and future logins will only '
                  'require your $biometricLabel.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ── How it works info card ────────────────────────────────────
                _InfoCard(biometricLabel: biometricLabel),
                const SizedBox(height: 32),

                // ── Form ─────────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email (read-only — for context)
                      TextFormField(
                        initialValue: email,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password confirmation
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Enter your account password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your password to confirm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Enable button
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isEnabling ? null : _handleEnable,
                          icon: _isEnabling
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(biometricIcon),
                          label: Text(
                            _isEnabling
                                ? 'Scanning…'
                                : 'Enable $biometricLabel Login',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Skip button
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isEnabling ? null : _skip,
                          child: const Text('Skip for Now'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Security note
                Text(
                  'Your credentials are encrypted using your device\'s '
                  'secure storage (Keychain / EncryptedSharedPreferences) '
                  'and are never uploaded to any server.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widget — "How it works" card
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final String biometricLabel;

  const _InfoCard({required this.biometricLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.looks_one_outlined,
            text: 'Confirm your password to link it to $biometricLabel.',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.looks_two_outlined,
            text: 'On future logins, tap "Auto-fill" and scan.',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.looks_3_outlined,
            text: 'Your email & password fill in automatically.',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
