// lib/screens/register_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } on Exception catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(dynamic e) {
    // 1. PRINT THE ACTUAL ERROR TO THE TERMINAL
    debugPrint("🚨 VAULT X DEBUG: $e");

    // 2. CHECK IF IT'S A FIREBASE EXCEPTION
    if (e is FirebaseAuthException) {
      debugPrint("Error Code: ${e.code}"); // e.g. 'operation-not-allowed'

      switch (e.code) {
        case 'email-already-in-use': return 'Email already registered.';
        case 'weak-password': return 'Password is too weak.';
        case 'invalid-email': return 'Invalid email format.';
        case 'operation-not-allowed': return 'Email/Password login is DISABLED in Firebase Console.';
        case 'network-request-failed': return 'Check your internet connection.';
        default: return e.message ?? 'An unknown error occurred.';
      }
    }
    return e.toString();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  VaultXTheme.accent.withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width > 600 ? size.width * 0.2 : 28,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: VaultXTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: VaultXTheme.border),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: VaultXTheme.textPrimary, size: 18),
                      ),
                    ).animate().fadeIn(),

                    const Gap(32),

                    Text(
                      'Create your\naccount ✨',
                      style: GoogleFonts.rajdhani(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: VaultXTheme.textPrimary,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                    const Gap(8),
                    Text(
                      'Secure all your passwords in one place.',
                      style: TextStyle(color: VaultXTheme.textSecondary, fontSize: 15),
                    ).animate().fadeIn(delay: 150.ms),

                    const Gap(36),

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
                            Expanded(child: Text(_error!, style: const TextStyle(color: VaultXTheme.danger, fontSize: 14))),
                          ],
                        ),
                      ).animate().shake(),

                    _buildLabel('Full Name'),
                    const Gap(8),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: VaultXTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'John Doe',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: VaultXTheme.textSecondary),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                    ).animate().fadeIn(delay: 200.ms),

                    const Gap(18),

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
                    ).animate().fadeIn(delay: 250.ms),

                    const Gap(18),

                    _buildLabel('Password'),
                    const Gap(8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: VaultXTheme.textPrimary),
                      onChanged: (_) => setState(() {}),
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
                    ).animate().fadeIn(delay: 300.ms),

                    // Strength bar
                    if (_passCtrl.text.isNotEmpty) ...[
                      const Gap(10),
                      _StrengthBar(password: _passCtrl.text),
                    ],

                    const Gap(18),

                    _buildLabel('Confirm Password'),
                    const Gap(8),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: VaultXTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: '••••••••••••',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: VaultXTheme.textSecondary),
                      ),
                      validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                    ).animate().fadeIn(delay: 350.ms),

                    const Gap(32),

                    SizedBox(
                      width: double.infinity,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: VaultXTheme.accent,
                                shadowColor: VaultXTheme.accent.withOpacity(0.4),
                                elevation: 12,
                              ),
                              child: const Text('Create Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

                    const Gap(32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: VaultXTheme.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Sign in', style: TextStyle(color: VaultXTheme.accent, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 450.ms),

                    const Gap(40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: VaultXTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}

class _StrengthBar extends StatelessWidget {
  final String password;
  const _StrengthBar({required this.password});

  double get strength {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 8) score += 0.25;
    if (password.length >= 12) score += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) score += 0.15;
    return score.clamp(0, 1);
  }

  Color get color {
    if (strength < 0.4) return VaultXTheme.danger;
    if (strength < 0.7) return VaultXTheme.warning;
    return VaultXTheme.success;
  }

  String get label {
    if (strength < 0.4) return 'Weak';
    if (strength < 0.7) return 'Fair';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: VaultXTheme.bgSurface,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
        const Gap(4),
        Text(
          'Password strength: $label',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
