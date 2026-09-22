import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

enum _FeedbackType { suggestion, bug, other }

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  _FeedbackType _selectedType = _FeedbackType.suggestion;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillContactInfo());
  }

  Future<void> _prefillContactInfo() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profile = await _firestoreService.getUserProfile(user.uid);
    if (!mounted) return;
    setState(() {
      _nameController.text =
          (profile?['displayName'] as String?) ?? user.displayName ?? '';
      _emailController.text =
          (profile?['email'] as String?) ?? user.email ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.support_coming_soon),
      ),
    );
  }

  String _typeValue(_FeedbackType type) => type.name;

  String _typeLabel(AppLocalizations loc, _FeedbackType type) {
    switch (type) {
      case _FeedbackType.suggestion:
        return loc.support_type_suggestion;
      case _FeedbackType.bug:
        return loc.support_type_bug;
      case _FeedbackType.other:
        return loc.support_type_other;
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    final userId = context.read<AuthProvider>().userId;

    try {
      await _firestoreService.submitFeedback(
        userId: userId,
        type: _typeValue(_selectedType),
        message: _messageController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        appVersion: AppConstants.appVersion,
      );

      if (!mounted) return;
      _messageController.clear();
      setState(() => _selectedType = _FeedbackType.suggestion);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.support_message_sent)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.export_error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  InputDecoration _inputDecoration([String? label]) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          loc.support_title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_balance_wallet,
                size: 64, color: AppColors.favorite),
            const SizedBox(height: 24),
            Text(
              loc.support_thank_you,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DonationButton(
                  label: loc.support_donate_2,
                  onTap: () => _showComingSoon(context),
                ),
                _DonationButton(
                  label: loc.support_donate_5,
                  onTap: () => _showComingSoon(context),
                ),
                _DonationButton(
                  label: loc.support_donate_10,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(color: AppColors.surface),
            const SizedBox(height: 24),
            Text(
              loc.support_contact_title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<_FeedbackType>(
                    initialValue: _selectedType,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration(),
                    items: _FeedbackType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(_typeLabel(loc, type)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _messageController,
                    minLines: 3,
                    maxLines: 6,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: loc.support_message_hint,
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? loc.validation_required
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration(loc.profile_name),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration(loc.profile_email),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(loc.support_send),
                    onPressed: _isSending ? null : _submitFeedback,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DonationButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
