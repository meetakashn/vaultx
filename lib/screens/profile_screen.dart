// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initial = name[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [VaultXTheme.accent, VaultXTheme.accentLight],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: VaultXTheme.accent.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

            const Gap(20),

            Text(
              name,
              style: GoogleFonts.rajdhani(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: VaultXTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const Gap(4),

            Text(
              email,
              style: const TextStyle(color: VaultXTheme.textSecondary, fontSize: 15),
            ).animate().fadeIn(delay: 150.ms),

            const Gap(40),

            // Info cards
            _InfoCard(
              icon: Icons.shield_outlined,
              iconColor: VaultXTheme.success,
              title: 'Encryption Status',
              subtitle: 'AES-256 End-to-End Encrypted',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: VaultXTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Active', style: TextStyle(color: VaultXTheme.success, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const Gap(12),

            _InfoCard(
              icon: Icons.email_outlined,
              iconColor: VaultXTheme.accent,
              title: 'Email Address',
              subtitle: email,
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),

            const Gap(12),

            _InfoCard(
              icon: Icons.lock_outline_rounded,
              iconColor: VaultXTheme.warning,
              title: 'Password',
              subtitle: 'Last changed on account creation',
              onTap: () => _resetPassword(context, email),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const Gap(32),

            // Security section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SECURITY',
                style: const TextStyle(
                  color: VaultXTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const Gap(12),

            _InfoCard(
              icon: Icons.info_outline_rounded,
              iconColor: VaultXTheme.textSecondary,
              title: 'About VaultX',
              subtitle: 'Version 1.0.0 — Built by AKASH NM',
            ).animate().fadeIn(delay: 350.ms),

            const Gap(32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded, color: VaultXTheme.danger),
                label: const Text('Sign Out', style: TextStyle(color: VaultXTheme.danger, fontWeight: FontWeight.w700, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: VaultXTheme.danger, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),

            const Gap(40),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: VaultXTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?', style: TextStyle(color: VaultXTheme.textPrimary)),
        content: const Text(
          'You will need to sign in again to access your vault.',
          style: TextStyle(color: VaultXTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: VaultXTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: VaultXTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _resetPassword(BuildContext context, String email) async {
    await AuthService.resetPassword(email);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent!'),
          backgroundColor: VaultXTheme.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: VaultXTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VaultXTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: VaultXTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  const Gap(2),
                  Text(subtitle, style: const TextStyle(color: VaultXTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            if (trailing != null) trailing!
            else if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, color: VaultXTheme.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
