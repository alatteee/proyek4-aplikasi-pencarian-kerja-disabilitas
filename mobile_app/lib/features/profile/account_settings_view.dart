import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'profile_controller.dart';

class AccountSettingsView extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const AccountSettingsView({super.key, required this.currentUser});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  final TextEditingController _passwordDisplayController =
      TextEditingController(text: '••••••••••••');

  @override
  void dispose() {
    _passwordDisplayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan Akun',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah Kata Sandi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                border: Border.all(
                  color: isDark ? Colors.yellow : Colors.grey.shade100,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.vpn_key_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _passwordDisplayController,
                      obscureText: false,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        letterSpacing: 2,
                        fontSize: 18,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        _showChangePasswordBottomSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: isDark
                              ? const BorderSide(color: Colors.yellow)
                              : BorderSide.none,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text(
                        'Ubah',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    final pageContext = context;
    final theme = Theme.of(pageContext);
    final isDark = theme.brightness == Brightness.dark;

    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> savePassword() async {
              if (isSaving) return;

              final oldPass = oldPassController.text.trim();
              final newPass = newPassController.text.trim();
              final confirmPass = confirmPassController.text.trim();

              if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  const SnackBar(
                    content: Text('Semua field harus diisi'),
                  ),
                );
                return;
              }

              if (newPass.length < 6) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  const SnackBar(
                    content: Text('Kata sandi baru minimal 6 karakter'),
                  ),
                );
                return;
              }

              if (newPass != confirmPass) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  const SnackBar(
                    content: Text('Konfirmasi password tidak cocok'),
                  ),
                );
                return;
              }

              setModalState(() {
                isSaving = true;
              });

              final success = await ProfileController.updatePassword(
                widget.currentUser['_id'],
                oldPass,
                newPass,
              );

              if (!mounted) return;

              setModalState(() {
                isSaving = false;
              });

              FocusScope.of(modalContext).unfocus();

              final messenger = ScaffoldMessenger.of(pageContext);

              await Future.delayed(const Duration(milliseconds: 200));

              if (!mounted) return;

              if (success) {
                Navigator.of(bottomSheetContext).pop();

                await Future.delayed(const Duration(milliseconds: 150));

                if (!mounted) return;

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Kata sandi berhasil diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Kata sandi lama tidak cocok atau gagal memperbarui kata sandi',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    border: isDark ? Border.all(color: Colors.yellow) : null,
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubah Kata Sandi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        modalContext,
                        label: 'Kata Sandi Lama',
                        controller: oldPassController,
                        isObscured: obscureOld,
                        onToggle: isSaving
                            ? null
                            : () {
                                setModalState(() {
                                  obscureOld = !obscureOld;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        modalContext,
                        label: 'Kata Sandi Baru',
                        controller: newPassController,
                        isObscured: obscureNew,
                        onToggle: isSaving
                            ? null
                            : () {
                                setModalState(() {
                                  obscureNew = !obscureNew;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        modalContext,
                        label: 'Konfirmasi Kata Sandi Baru',
                        controller: confirmPassController,
                        isObscured: obscureConfirm,
                        onToggle: isSaving
                            ? null
                            : () {
                                setModalState(() {
                                  obscureConfirm = !obscureConfirm;
                                });
                              },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : savePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor:
                                isDark ? Colors.black : Colors.white,
                            disabledBackgroundColor:
                                theme.colorScheme.primary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        isDark ? Colors.black : Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback? onToggle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscured,
          enabled: onToggle != null,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.yellow : Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.yellow : Colors.grey.shade200,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.yellow : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}