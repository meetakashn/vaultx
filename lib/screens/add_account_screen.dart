// lib/screens/add_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account_entry.dart';
import '../services/vault_service.dart';
import '../services/password_generator.dart';
import '../utils/theme.dart';

class AddAccountScreen extends StatefulWidget {
  final String vaultId;
  final int vaultColor;
  final AccountEntry? existingEntry;

  const AddAccountScreen({
    super.key,
    required this.vaultId,
    required this.vaultColor,
    this.existingEntry,
  });

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  bool get _isEditing => widget.existingEntry != null;

  // Generator state
  int _genLength = 16;
  bool _genUpper = true;
  bool _genLower = true;
  bool _genDigits = true;
  bool _genSpecial = true;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _labelCtrl.text = widget.existingEntry!.label;
      _usernameCtrl.text = widget.existingEntry!.username;
      _passwordCtrl.text = widget.existingEntry!.password;
      _notesCtrl.text = widget.existingEntry!.notes;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final entry = AccountEntry(
        id: widget.existingEntry?.id,
        label: _labelCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        notes: _notesCtrl.text.trim(),
      );
      if (_isEditing) {
        await VaultService.updateAccount(widget.vaultId, entry);
      } else {
        await VaultService.addAccount(widget.vaultId, entry);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _generatePassword() {
    final generated = PasswordGenerator.generate(
      length: _genLength,
      useUpper: _genUpper,
      useLower: _genLower,
      useDigits: _genDigits,
      useSpecial: _genSpecial,
    );
    setState(() => _passwordCtrl.text = generated);
  }

  void _showGenerator() {
    showModalBottomSheet(
      context: context,
      backgroundColor: VaultXTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: VaultXTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Password Generator', style: GoogleFonts.rajdhani(
                fontSize: 22, fontWeight: FontWeight.w700, color: VaultXTheme.textPrimary)),

              const Gap(20),

              // Generated password preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VaultXTheme.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VaultXTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _passwordCtrl.text.isEmpty ? 'Press Generate' : _passwordCtrl.text,
                        style: TextStyle(
                          color: _passwordCtrl.text.isEmpty ? VaultXTheme.textMuted : VaultXTheme.textPrimary,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_passwordCtrl.text.isNotEmpty)
                      _strengthChip(_passwordCtrl.text),
                  ],
                ),
              ),

              const Gap(20),

              // Length slider
              Row(
                children: [
                  const Text('Length', style: TextStyle(color: VaultXTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(widget.vaultColor).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_genLength',
                      style: TextStyle(color: Color(widget.vaultColor), fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _genLength.toDouble(),
                min: 8,
                max: 32,
                divisions: 24,
                activeColor: Color(widget.vaultColor),
                inactiveColor: VaultXTheme.bgSurface,
                onChanged: (v) => setModal(() => _genLength = v.round()),
              ),

              // Toggles
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Toggle(label: 'A-Z', value: _genUpper, color: Color(widget.vaultColor),
                    onChanged: (v) => setModal(() => _genUpper = v)),
                  _Toggle(label: 'a-z', value: _genLower, color: Color(widget.vaultColor),
                    onChanged: (v) => setModal(() => _genLower = v)),
                  _Toggle(label: '0-9', value: _genDigits, color: Color(widget.vaultColor),
                    onChanged: (v) => setModal(() => _genDigits = v)),
                  _Toggle(label: '!@#', value: _genSpecial, color: Color(widget.vaultColor),
                    onChanged: (v) => setModal(() => _genSpecial = v)),
                ],
              ),

              const Gap(24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _generatePassword();
                    setModal(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(widget.vaultColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
                      Gap(8),
                      Text('Generate Password', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),

              if (_passwordCtrl.text.isNotEmpty) ...[
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(widget.vaultColor)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Color(widget.vaultColor),
                    ),
                    child: const Text('Use This Password', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _strengthChip(String password) {
    final s = PasswordGenerator.strength(password);
    Color c = s < 0.4 ? VaultXTheme.danger : s < 0.7 ? VaultXTheme.warning : VaultXTheme.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(PasswordGenerator.strengthLabel(s), style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.vaultColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Account' : 'Add Account',
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
            _label('Account Label'),
            const Gap(8),
            TextFormField(
              controller: _labelCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: VaultXTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Personal, Work, Gaming',
                prefixIcon: Icon(Icons.label_outline_rounded, color: color),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a label' : null,
            ).animate().fadeIn(delay: 100.ms),

            const Gap(20),

            _label('Username / Email'),
            const Gap(8),
            TextFormField(
              controller: _usernameCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: VaultXTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'username or email',
                prefixIcon: Icon(Icons.alternate_email_rounded, color: color),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter username or email' : null,
            ).animate().fadeIn(delay: 150.ms),

            const Gap(20),

            Row(
              children: [
                Expanded(child: _label('Password')),
                GestureDetector(
                  onTap: _showGenerator,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: color),
                        const Gap(4),
                        Text('Generate', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: VaultXTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter or generate a password',
                prefixIcon: Icon(Icons.lock_outline_rounded, color: color),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_passwordCtrl.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _strengthChip(_passwordCtrl.text),
                      ),
                    IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: VaultXTheme.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ],
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a password' : null,
            ).animate().fadeIn(delay: 200.ms),

            if (_passwordCtrl.text.isNotEmpty) ...[
              const Gap(8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: PasswordGenerator.strength(_passwordCtrl.text),
                  backgroundColor: VaultXTheme.bgSurface,
                  valueColor: AlwaysStoppedAnimation(
                    PasswordGenerator.strength(_passwordCtrl.text) < 0.4
                        ? VaultXTheme.danger
                        : PasswordGenerator.strength(_passwordCtrl.text) < 0.7
                            ? VaultXTheme.warning
                            : VaultXTheme.success,
                  ),
                  minHeight: 4,
                ),
              ),
            ],

            const Gap(20),

            _label('Notes (optional)'),
            const Gap(8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              style: const TextStyle(color: VaultXTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Any extra info...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_rounded, color: VaultXTheme.textSecondary),
                ),
              ),
            ).animate().fadeIn(delay: 250.ms),

            const Gap(40),

            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shadowColor: color.withOpacity(0.4),
                        elevation: 8,
                      ),
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Add Account',
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

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.label, required this.value, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.15) : VaultXTheme.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value ? color : VaultXTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: value ? color : VaultXTheme.textSecondary,
            fontWeight: value ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
