import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_view.dart';
import 'widgets/profile_menu_item.dart';
import 'profile_detail_view.dart';

class ProfileView extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const ProfileView({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                 child: const Icon(Icons.person, size: 50, color: AppColors.primaryNavy),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       currentUser['username'] ?? 'User',
                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                     ),
                     const SizedBox(height: 2),
                     Text(
                       currentUser['email'] ?? '-',
                       style: const TextStyle(fontSize: 14, color: AppColors.textGray),
                     ),
                     const SizedBox(height: 14),
                     SizedBox(
                       height: 36,
                       width: 120, // fixed width for button
                       child: OutlinedButton(
                         onPressed: () {
                           Navigator.push(context, MaterialPageRoute(
                             builder: (_) => ProfileDetailView(currentUser: currentUser)
                           ));
                         },
                         style: OutlinedButton.styleFrom(
                           padding: EdgeInsets.zero,
                           foregroundColor: AppColors.primaryNavy,
                           side: const BorderSide(color: AppColors.primaryNavy),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('Lihat Profil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
           
           const SizedBox(height: 32),
           
           // List Menus
           ProfileMenuItem(icon: Icons.bookmark, label: 'Lowongan Tersimpan', onTap: () {}),
           ProfileMenuItem(icon: Icons.accessibility_new, label: 'Pengaturan Aksesibilitas', onTap: () {}),
           ProfileMenuItem(icon: Icons.settings, label: 'Pengaturan Akun', onTap: () {}),
           ProfileMenuItem(icon: Icons.help, label: 'Bantuan', onTap: () {}),
           ProfileMenuItem(icon: Icons.info, label: 'Tentang Aplikasi', onTap: () {}),
           
           // Logout Menu
           ProfileMenuItem(
             icon: Icons.logout,
             label: 'Logout', 
             onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
             },
           ),
           
           const SizedBox(height: 20),
        ],
      ),
    );
  }
}
