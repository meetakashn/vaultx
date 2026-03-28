// lib/screens/vault_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vault_item.dart';
import '../models/account_entry.dart';
import '../services/vault_service.dart';
import '../utils/theme.dart';
import 'add_account_screen.dart';

class VaultDetailScreen extends StatelessWidget {
  final VaultItem vault;
  const VaultDetailScreen({super.key, required this.vault});

  @override
  Widget build(BuildContext context) {
    final color = Color(vault.colorValue);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: VaultXTheme.bgDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddAccountScreen(vaultId: vault.id!, vaultColor: vault.colorValue),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      color.withOpacity(0.3),
                      VaultXTheme.bgDark,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Text(vault.emoji, style: const TextStyle(fontSize: 30)),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vault.title,
                              style: GoogleFonts.rajdhani(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: VaultXTheme.textPrimary,
                              ),
                            ),
                            Text(
                              vault.category,
                              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Accounts list
          StreamBuilder<List<AccountEntry>>(
            stream: VaultService.streamAccounts(vault.id!),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: VaultXTheme.accent)),
                );
              }

              final encrypted = snap.data ?? [];
              if (encrypted.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🗝️', style: TextStyle(fontSize: 56)),
                        const Gap(16),
                        Text(
                          'No accounts yet',
                          style: GoogleFonts.rajdhani(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: VaultXTheme.textPrimary,
                          ),
                        ),
                        const Gap(8),
                        const Text(
                          'Tap + to add your first account',
                          style: TextStyle(color: VaultXTheme.textSecondary),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final entry = VaultService.decryptAccount(encrypted[i]);
                      return _AccountCard(
                        entry: entry,
                        color: color,
                        index: i,
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddAccountScreen(
                              vaultId: vault.id!,
                              vaultColor: vault.colorValue,
                              existingEntry: entry,
                            ),
                          ),
                        ),
                        onDelete: () => _confirmDelete(context, vault.id!, entry),
                      );
                    },
                    childCount: encrypted.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddAccountScreen(vaultId: vault.id!, vaultColor: vault.colorValue),
          ),
        ),
        backgroundColor: color,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _confirmDelete(BuildContext context, String vaultId, AccountEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: VaultXTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account?', style: TextStyle(color: VaultXTheme.textPrimary)),
        content: Text(
          'Remove "${entry.label}" from this vault?',
          style: const TextStyle(color: VaultXTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: VaultXTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await VaultService.deleteAccount(vaultId, entry.id!);
            },
            child: const Text('Delete', style: TextStyle(color: VaultXTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatefulWidget {
  final AccountEntry entry;
  final Color color;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountCard({
    required this.entry,
    required this.color,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  bool _showPassword = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: VaultXTheme.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    // Auto-clear clipboard after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: VaultXTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VaultXTheme.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(Icons.person_outline_rounded, color: widget.color, size: 18),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    widget.entry.label,
                    style: const TextStyle(
                      color: VaultXTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: VaultXTheme.textSecondary),
                  onPressed: widget.onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: VaultXTheme.danger),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          // Fields
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _FieldRow(
                  icon: Icons.alternate_email_rounded,
                  label: 'Username / Email',
                  value: widget.entry.username,
                  color: widget.color,
                  onCopy: () => _copyToClipboard(widget.entry.username, 'Username'),
                ),
                const Gap(14),
                _PasswordRow(
                  password: widget.entry.password,
                  color: widget.color,
                  showPassword: _showPassword,
                  onToggle: () => setState(() => _showPassword = !_showPassword),
                  onCopy: () => _copyToClipboard(widget.entry.password, 'Password'),
                ),
                if (widget.entry.notes.isNotEmpty) ...[
                  const Gap(14),
                  _FieldRow(
                    icon: Icons.notes_rounded,
                    label: 'Notes',
                    value: widget.entry.notes,
                    color: widget.color,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 60 * widget.index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onCopy;

  const _FieldRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VaultXTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: VaultXTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                const Gap(2),
                Text(value, style: const TextStyle(color: VaultXTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.copy_rounded, color: color, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class _PasswordRow extends StatelessWidget {
  final String password;
  final Color color;
  final bool showPassword;
  final VoidCallback onToggle;
  final VoidCallback onCopy;

  const _PasswordRow({
    required this.password,
    required this.color,
    required this.showPassword,
    required this.onToggle,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VaultXTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: color, size: 16),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Password', style: TextStyle(color: VaultXTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                const Gap(2),
                Text(
                  showPassword ? password : '•' * password.length.clamp(8, 16),
                  style: TextStyle(
                    color: VaultXTheme.textPrimary,
                    fontSize: showPassword ? 14 : 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: showPassword ? 0 : 2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: VaultXTheme.bgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: VaultXTheme.textSecondary,
                size: 16,
              ),
            ),
          ),
          const Gap(8),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.copy_rounded, color: color, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
