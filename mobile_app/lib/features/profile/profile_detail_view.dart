import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'profile_controller.dart';
import 'edit_profile_view.dart';
import 'widgets/skill_chip.dart';
import 'widgets/profile_info_field.dart';
import 'dart:io';

class ProfileDetailView extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const ProfileDetailView({super.key, required this.currentUser});

  @override
  State<ProfileDetailView> createState() => _ProfileDetailViewState();
}

class _ProfileDetailViewState extends State<ProfileDetailView> {
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { isLoading = true; });
    final profile = await ProfileController.getProfileByUserId(widget.currentUser['_id']);
    setState(() {
      userDetails = profile;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
      );
    }

    final namaLengkap = userDetails?['nama_lengkap'] ?? widget.currentUser['username'] ?? 'Belum diisi';
    final email = userDetails?['email'] ?? widget.currentUser['email'] ?? 'Belum diisi';
    final noHp = userDetails?['phone'] ?? widget.currentUser['phone'] ?? 'Belum diisi';
    final jenisKelamin = userDetails?['jenis_kelamin'] ?? 'Belum diisi';
    final jenisDisabilitas = userDetails?['jenis_disabilitas'] ?? 'Belum diisi';
    final deskripsiDisabilitas = userDetails?['deskripsi_disabilitas'] ?? 'Belum diisi';
    final List<dynamic> skillsData = userDetails?['skills'] ?? [];
    List<String> skills = skillsData.map((e) => e.toString()).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context, true),        ),
        title: const Text(
          'Detail Profil',
          style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
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
                        namaLengkap,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 14, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Info Fields
            ProfileInfoField(label: 'Nama Lengkap', value: namaLengkap),
            ProfileInfoField(label: 'No. Handphone', value: noHp),
            ProfileInfoField(label: 'Email', value: email),
            ProfileInfoField(label: 'Jenis Kelamin', value: jenisKelamin),
            ProfileInfoField(label: 'Jenis Disabilitas', value: jenisDisabilitas),
            ProfileInfoField(label: 'Deskripsi Disabilitas', value: deskripsiDisabilitas),

            // Skills
            const Text(
              'Kemampuan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            skills.isEmpty 
              ? const Text('Belum ada kemampuan ditambahkan', style: TextStyle(color: AppColors.textGray))
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: skills.map((s) => SkillChip(label: s)).toList(),
                ),

            const SizedBox(height: 48),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => EditProfileView(
                      currentUser: widget.currentUser,
                      userDetails: userDetails,
                    )
                  ));
                  if (result == true) {
                    _loadProfile();
                  }
                },
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
