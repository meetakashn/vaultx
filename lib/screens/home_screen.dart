// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vault_item.dart';
import '../services/auth_service.dart';
import '../services/vault_service.dart';
import '../utils/theme.dart';
import 'login_screen.dart';
import 'vault_detail_screen.dart';
import 'add_vault_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search = '';
  int _bottomIndex = 0;
  String? _selectedCategory;

  static const List<String> _categories = [
    'All', 'Social', 'Banking', 'Work', 'Shopping', 'Entertainment', 'General',
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final firstName = (user?.displayName ?? 'User').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, $firstName 👋',
                          style: const TextStyle(
                            color: VaultXTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Your Vault',
                          style: GoogleFonts.rajdhani(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: VaultXTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avatar
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [VaultXTheme.accent, VaultXTheme.accentLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: VaultXTheme.accent.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          firstName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const Gap(20),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: VaultXTheme.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VaultXTheme.border),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: VaultXTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search vaults...',
                    prefixIcon: Icon(Icons.search_rounded, color: VaultXTheme.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const Gap(16),

            // Category chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const Gap(8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isSelected = cat == 'All'
                      ? _selectedCategory == null
                      : _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _selectedCategory = cat == 'All' ? null : cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? VaultXTheme.accent : VaultXTheme.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? VaultXTheme.accent : VaultXTheme.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : VaultXTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 150.ms),

            const Gap(20),

            // Vault grid
            Expanded(
              child: StreamBuilder<List<VaultItem>>(
                stream: VaultService.streamVaults(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: VaultXTheme.accent),
                    );
                  }

                  final all = snap.data ?? [];
                  final filtered = all.where((v) {
                    final matchSearch = _search.isEmpty ||
                        v.title.toLowerCase().contains(_search.toLowerCase());
                    final matchCat = _selectedCategory == null ||
                        v.category == _selectedCategory;
                    return matchSearch && matchCat;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _EmptyState(hasItems: all.isNotEmpty);
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _VaultTile(
                      item: filtered[i],
                      index: i,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VaultDetailScreen(vault: filtered[i]),
                        ),
                      ),
                      onDelete: () => _confirmDelete(filtered[i]),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddVaultScreen(existingVault: filtered[i]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddVaultScreen()),
        ),
        backgroundColor: VaultXTheme.accent,
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Vault',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ).animate().scale(delay: 500.ms),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _confirmDelete(VaultItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: VaultXTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Vault?', style: TextStyle(color: VaultXTheme.textPrimary)),
        content: Text(
          'This will permanently delete "${item.title}" and all its passwords.',
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
              await VaultService.deleteVault(item.id!);
            },
            child: const Text('Delete', style: TextStyle(color: VaultXTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _VaultTile extends StatefulWidget {
  final VaultItem item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _VaultTile({
    required this.item,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_VaultTile> createState() => _VaultTileState();
}

class _VaultTileState extends State<_VaultTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.item.colorValue);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () => _showActions(),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: VaultXTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VaultXTheme.border),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient top strip
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.3)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(6),
                    // Emoji circle
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(widget.item.emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),

                    const Spacer(),

                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        color: VaultXTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Gap(4),

                    Row(
                      children: [
                        Icon(Icons.key_rounded, color: color, size: 13),
                        const Gap(4),
                        Text(
                          widget.item.category,
                          style: TextStyle(
                            color: VaultXTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 50 * widget.index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  void _showActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: VaultXTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: VaultXTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: VaultXTheme.accent),
            title: const Text('Edit Vault', style: TextStyle(color: VaultXTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              widget.onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: VaultXTheme.danger),
            title: const Text('Delete Vault', style: TextStyle(color: VaultXTheme.danger)),
            onTap: () {
              Navigator.pop(context);
              widget.onDelete();
            },
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasItems;
  const _EmptyState({required this.hasItems});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(hasItems ? '🔍' : '🔐', style: const TextStyle(fontSize: 64)),
          const Gap(16),
          Text(
            hasItems ? 'No results found' : 'Your vault is empty',
            style: GoogleFonts.rajdhani(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: VaultXTheme.textPrimary,
            ),
          ),
          const Gap(8),
          Text(
            hasItems ? 'Try a different search or category.' : 'Tap "Add Vault" to get started.',
            style: const TextStyle(color: VaultXTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
