import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class JobDetailPage extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobDetailPage({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = job['title'] ?? '-';
    final String company = job['company_name'] ?? '-';
    final String location = job['location'] ?? '-';
    final String jobType = job['job_type'] ?? '-';
    final String description = job['description'] ?? 'Tidak ada deskripsi.';
    final List qualifications = (job['qualification'] is List)
        ? job['qualification']
        : (job['qualification'] is String && job['qualification'].isNotEmpty)
            ? job['qualification'].split('\n')
            : [];
    final List facilities = (job['facilities'] is List)
        ? job['facilities']
        : (job['facilities'] is String && job['facilities'].isNotEmpty)
            ? job['facilities'].split(',')
            : [];

    IconData getFacilityIcon(String name) {
      final lower = name.toLowerCase();
      if (lower.contains('akses')) return Icons.accessible;
      if (lower.contains('asuransi') || lower.contains('kesehat')) return Icons.health_and_safety;
      return Icons.check_circle_outline;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Lowongan', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon dan judul
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.headset_mic, color: AppColors.primaryNavy, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                        const SizedBox(height: 4),
                        Text(company, style: const TextStyle(fontSize: 15, color: AppColors.textGray)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.textGray),
                            const SizedBox(width: 4),
                            Text(location, style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
                            const SizedBox(width: 16),
                            const Icon(Icons.work, size: 16, color: AppColors.textGray),
                            const SizedBox(width: 4),
                            Text(jobType, style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Deskripsi Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
              const SizedBox(height: 24),
              const Text('Kualifikasi Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
              const SizedBox(height: 8),
              if (qualifications.isEmpty)
                const Text('Tidak ada kualifikasi.', style: TextStyle(color: AppColors.textGray, fontSize: 14))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: qualifications.map<Widget>((q) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16, color: Colors.black87)),
                      Expanded(child: Text(q.toString(), style: const TextStyle(fontSize: 14, color: Colors.black87))),
                    ],
                  )).toList(),
                ),
              const SizedBox(height: 24),
              const Text('Fasilitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
              const SizedBox(height: 8),
              if (facilities.isEmpty)
                const Text('Tidak ada fasilitas.', style: TextStyle(color: AppColors.textGray, fontSize: 14))
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: facilities.map<Widget>((f) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(getFacilityIcon(f.toString()), color: AppColors.primaryNavy, size: 22),
                        const SizedBox(width: 8),
                        Text(f.toString(), style: const TextStyle(fontSize: 13, color: AppColors.primaryNavy, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )).toList(),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lamar Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
