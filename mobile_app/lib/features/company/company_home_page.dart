import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CompanyHomePage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool showSuccessDialog;

  const CompanyHomePage({
    super.key,
    required this.userData,
    this.showSuccessDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    final companyName =
        userData['companyName'] ?? userData['name'] ?? 'Perusahaan';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard Perusahaan'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Selamat datang, $companyName',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryNavy,
          ),
        ),
      ),
    );
  }
}