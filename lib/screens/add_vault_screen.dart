// lib/screens/add_vault_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vault_item.dart';
import '../services/vault_service.dart';
import '../utils/theme.dart';

class AddVaultScreen extends StatefulWidget {
  final VaultItem? existingVault;
  const AddVaultScreen({super.key, this.existingVault});

  @override
  State<AddVaultScreen> createState() => _AddVaultScreenState();
}

class _AddVaultScreenState extends State<AddVaultScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String _selectedEmoji = '🔐';
  int _selectedColor = 0xFF6C63FF;
  String _selectedCategory = 'General';
  bool _loading = false;

  bool get _isEditing => widget.existingVault != null;

  static const List<String> _categories = [
    'General', 'Social', 'Banking', 'Work', 'Shopping', 'Entertainment',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.existingVault!.title;
      _selectedEmoji = widget.existingVault!.emoji;
      _selectedColor = widget.existingVault!.colorValue;
      _selectedCategory = widget.existingVault!.category;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final item = VaultItem(
        id: widget.existingVault?.id,
        title: _titleCtrl.text.trim(),
        emoji: _selectedEmoji,
        colorValue: _selectedColor,
        category: _selectedCategory,
      );
      if (_isEditing) {
        await VaultService.updateVault(item);
      } else {
        await VaultService.addVault(item);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Vault' : 'New Vault',
          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Preview
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Color(_selectedColor).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color(_selectedColor).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(_selectedEmoji, style: const TextStyle(fontSize: 42)),
                ),
              ).animate().scale(duration: 200.ms),
            ),

            const Gap(32),

            _label('Vault Title'),
            const Gap(8),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: VaultXTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'e.g. Instagram, Bank, Work',
                prefixIcon: Icon(Icons.title_rounded, color: VaultXTheme.textSecondary),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),

            const Gap(28),

            _label('Choose Icon'),
            const Gap(12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: kDefaultIcons.map((icon) {
                final isSelected = _selectedEmoji == icon['emoji'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = icon['emoji']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(_selectedColor).withOpacity(0.2)
                          : VaultXTheme.bgSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Color(_selectedColor) : VaultXTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(icon['emoji'], style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Gap(28),

            _label('Choose Color'),
            const Gap(12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: kCategoryColors.map((c) {
                final isSelected = _selectedColor == c['color'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c['color']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c['color']),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Color(c['color']).withOpacity(0.5), blurRadius: 12)]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const Gap(28),

            _label('Category'),
            const Gap(12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(_selectedColor) : VaultXTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Color(_selectedColor) : VaultXTheme.border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : VaultXTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Gap(40),

            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(_selectedColor),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 8,
                        shadowColor: Color(_selectedColor).withOpacity(0.4),
                      ),
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Create Vault',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
            ),

            const Gap(40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: VaultXTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}
