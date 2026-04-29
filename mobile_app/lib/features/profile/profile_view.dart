import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_view.dart';
import 'widgets/profile_menu_item.dart';
import 'profile_detail_view.dart';
import 'account_settings_view.dart';
import 'help_view.dart';
import 'about_view.dart';
import '../saved_jobs/saved_jobs_page.dart';
import 'profile_controller.dart';
import 'dart:io';
import 'accessibility_settings_view.dart';

class ProfileView extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const ProfileView({super.key, required this.currentUser});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = widget.currentUser['_id'];

    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    final profile = await ProfileController.getProfileByUserId(userId);

    if (!mounted) return;

    setState(() {
      userDetails = profile;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryNavy),
      );
    }

    return RefreshIndicator(
    color: AppColors.primaryNavy,
    onRefresh: _loadProfile,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          // User Profile Header
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: userDetails?['profile_photo'] != null &&
                        userDetails!['profile_photo'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(userDetails!['profile_photo']),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryNavy,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userDetails?['nama_lengkap'] ??
                          widget.currentUser['username'] ??
                          'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userDetails?['email'] ??
                          widget.currentUser['email'] ??
                          '-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 36,
                      width: 120,
                      child: OutlinedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileDetailView(
                                currentUser: widget.currentUser,
                              ),
                            ),
                          );

                          if (result == true) {
                            _loadProfile();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: AppColors.primaryNavy,
                          side: const BorderSide(color: AppColors.primaryNavy),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Lihat Profil',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          ProfileMenuItem(
            icon: Icons.bookmark,
            label: 'Lowongan Tersimpan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavedJobsPage(currentUser: widget.currentUser),
                ),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.accessibility_new,
            label: 'Pengaturan Aksesibilitas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccessibilitySettingsView(),
                ),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.settings,
            label: 'Pengaturan Akun',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AccountSettingsView(currentUser: widget.currentUser),
                ),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.help,
            label: 'Bantuan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpView()),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.info,
            label: 'Tentang Aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutView()),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () => _showLogoutDialog(context),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            // Tombol Close (X) di pojok kanan atas
            Positioned(
              right: 12,
              top: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primaryNavy, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon sesuai Mockup
                  const Icon(
                    Icons.logout_rounded, 
                    size: 100, 
                    color: AppColors.primaryNavy,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Logout Account?',
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Apakah anda yakin akan logout\ndari akun anda?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey, 
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      // Tombol Cancel
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE5E7EB), // Light gray
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Cancel', 
                              style: TextStyle(
                                color: Colors.black87, 
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tombol Logout
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginView()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Logout', 
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
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
    );
  }
}
