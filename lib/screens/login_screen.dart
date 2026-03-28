// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on Exception catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String e) {
    if (e.contains('user-not-found')) return 'No account with this email.';
    if (e.contains('wrong-password')) return 'Incorrect password.';
    if (e.contains('invalid-email')) return 'Invalid email address.';
    if (e.contains('too-many-requests')) return 'Too many attempts. Try later.';
    return 'Login failed. Please try again.';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background glow effects
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    VaultXTheme.accent.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    VaultXTheme.accentLight.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width > 600 ? size.width * 0.2 : 28,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 👈 Tells Column to only take needed height
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(40),

                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [VaultXTheme.accent, VaultXTheme.accentLight],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: VaultXTheme.accent.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🔐', style: TextStyle(fontSize: 26)),
                            ),
                          ),
                          const Gap(14),
                          Text(
                            'VaultX',
                            style: GoogleFonts.rajdhani(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: VaultXTheme.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                      const Gap(48),

                      Text(
                        'Welcome\nback 👋',
                        style: GoogleFonts.rajdhani(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: VaultXTheme.textPrimary,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

                      const Gap(8),

                      Text(
                        'Your passwords are safe with us.',
                        style: TextStyle(
                          color: VaultXTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const Gap(40),

                      // Error banner
                      if (_error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: VaultXTheme.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VaultXTheme.danger.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: VaultXTheme.danger, size: 18),
                              const Gap(10),
                              Expanded(
                                child: Text(_error!, style: const TextStyle(color: VaultXTheme.danger, fontSize: 14)),
                              ),
                            ],
                          ),
                        ).animate().shake(),

                      // Email
                      _buildLabel('Email'),
                      const Gap(8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: VaultXTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded, color: VaultXTheme.textSecondary),
                        ),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                      ).animate().fadeIn(delay: 300.ms),

                      const Gap(20),

                      // Password
                      _buildLabel('Password'),
                      const Gap(8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: VaultXTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: '••••••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: VaultXTheme.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: VaultXTheme.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                      ).animate().fadeIn(delay: 350.ms),

                      const Gap(12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPassword(),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(color: VaultXTheme.accent, fontSize: 14),
                          ),
                        ),
                      ),

                      const Gap(28),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: VaultXTheme.accent,
                                  shadowColor: VaultXTheme.accent.withOpacity(0.4),
                                  elevation: 12,
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                                ),
                              ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

                      const Gap(32),

                      // Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: VaultXTheme.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: Text(
                              'Create one',
                              style: TextStyle(
                                color: VaultXTheme.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),

                      const Gap(40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: VaultXTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: VaultXTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), // Keeps it clean on Web
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: GoogleFonts.rajdhani(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: VaultXTheme.textPrimary,
                  ),
                ),
                const Gap(12),
                const Text(
                  'Enter your email to receive a password reset link.',
                  style: TextStyle(color: VaultXTheme.textSecondary, fontSize: 14),
                ),
                const Gap(24),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: VaultXTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const Gap(32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: VaultXTheme.textSecondary)),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (ctrl.text.isNotEmpty) {
                            await AuthService.resetPassword(ctrl.text.trim());
                            if (mounted) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reset email sent!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Send Link'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
