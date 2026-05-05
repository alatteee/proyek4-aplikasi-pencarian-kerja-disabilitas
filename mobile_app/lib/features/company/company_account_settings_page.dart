import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../../core/constants/app_colors.dart';
import '../profile/profile_controller.dart';

class CompanyAccountSettingsPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const CompanyAccountSettingsPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<CompanyAccountSettingsPage> createState() =>
      _CompanyAccountSettingsPageState();
}

class _CompanyAccountSettingsPageState
    extends State<CompanyAccountSettingsPage> {
  final TextEditingController _passwordDisplayController =
      TextEditingController(text: '••••••••••••');

  static const Color navy = Color(0xFF0B1B55);
  static const Color textDark = Color(0xFF07122F);
  static const Color subtitle = Color(0xFF8D94A6);

  @override
  void dispose() {
    _passwordDisplayController.dispose();
    super.dispose();
  }

  mongo.ObjectId? _getCurrentUserId() {
    final id = widget.currentUser['_id'];

    if (id is mongo.ObjectId) {
      return id;
    }

    if (id != null) {
      try {
        return mongo.ObjectId.fromHexString(id.toString());
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Kalau page ini dibuka dari tab Profil CompanyHomePage,
      // bottom navigation tetap muncul karena page ini di-push dari dalam tab.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 48),

              const Text(
                'Ubah Kata Sandi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: navy,
                ),
              ),

              const SizedBox(height: 18),

              _buildPasswordCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: navy,
            size: 36,
          ),
        ),

        const SizedBox(width: 20),

        const Expanded(
          child: Text(
            'Pengaturan Akun',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.vpn_key_rounded,
            color: navy,
            size: 34,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: TextField(
              controller: _passwordDisplayController,
              readOnly: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: subtitle,
                letterSpacing: 4,
              ),
            ),
          ),

          const SizedBox(width: 14),

          SizedBox(
            width: 86,
            height: 48,
            child: ElevatedButton(
              onPressed: _showChangePasswordBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ubah',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordBottomSheet() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 28,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'Ubah Kata Sandi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: navy,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildPasswordInput(
                      label: 'Kata Sandi Lama',
                      controller: oldPassController,
                      isObscured: obscureOld,
                      onToggle: () {
                        setModalState(() {
                          obscureOld = !obscureOld;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildPasswordInput(
                      label: 'Kata Sandi Baru',
                      controller: newPassController,
                      isObscured: obscureNew,
                      onToggle: () {
                        setModalState(() {
                          obscureNew = !obscureNew;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildPasswordInput(
                      label: 'Konfirmasi Kata Sandi Baru',
                      controller: confirmPassController,
                      isObscured: obscureConfirm,
                      onToggle: () {
                        setModalState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final oldPass = oldPassController.text.trim();
                          final newPass = newPassController.text.trim();
                          final confirmPass =
                              confirmPassController.text.trim();

                          if (oldPass.isEmpty ||
                              newPass.isEmpty ||
                              confirmPass.isEmpty) {
                            _showSnackBar(
                              'Semua field harus diisi',
                              color: Colors.red,
                            );
                            return;
                          }

                          if (newPass.length < 6) {
                            _showSnackBar(
                              'Kata sandi baru minimal 6 karakter',
                              color: Colors.red,
                            );
                            return;
                          }

                          if (newPass != confirmPass) {
                            _showSnackBar(
                              'Konfirmasi kata sandi tidak cocok',
                              color: Colors.red,
                            );
                            return;
                          }

                          _showConfirmUpdateDialog(
                            oldPass: oldPass,
                            newPass: newPass,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordInput({
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: isObscured,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: navy,
                size: 22,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: navy,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmUpdateDialog({
    required String oldPass,
    required String newPass,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Konfirmasi',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Apakah anda yakin ingin mengubah kata sandi anda?',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _updatePassword(
                  oldPass: oldPass,
                  newPass: newPass,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Ya, Ubah',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword({
    required String oldPass,
    required String newPass,
  }) async {
    final userId = _getCurrentUserId();

    if (userId == null) {
      _showSnackBar(
        'User tidak valid. Silakan login ulang.',
        color: Colors.red,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(22),
              child: CircularProgressIndicator(
                color: navy,
              ),
            ),
          ),
        );
      },
    );

    try {
      final success = await ProfileController.updatePassword(
        userId,
        oldPass,
        newPass,
      );

      if (!mounted) return;

      Navigator.pop(context); // tutup loading

      if (success) {
        Navigator.pop(context); // tutup bottom sheet
        _showSuccessDialog();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // tutup loading
      _showSnackBar(
        'Gagal mengubah kata sandi',
        color: Colors.red,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (successContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),

              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 68,
              ),

              const SizedBox(height: 22),

              const Text(
                'Berhasil!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: navy,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Kata sandi Anda telah berhasil diperbarui.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(successContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (errorContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
              SizedBox(width: 8),
              Text(
                'Perhatian',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: const Text(
            'Kata sandi lama yang Anda masukkan tidak cocok. Silakan periksa kembali.',
            style: TextStyle(
              fontSize: 15,
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(errorContext),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}