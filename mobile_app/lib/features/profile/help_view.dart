import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'azkha.nazzala.tif24@polban.ac.id',
      query: 'subject=Bantuan Aplikasi JobAble',
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch $emailLaunchUri');
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/6282119765944");
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $whatsappUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bantuan',
          style: TextStyle(
            color: AppColors.primaryNavy,
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
            const Text(
              'Temukan informasi dan bantuan untuk menggunakan aplikasi JobAble',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280), // Modern gray
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildHelpCard(
              icon: Icons.help_outline,
              title: 'Cara Menggunakan',
              subtitle: 'Ikuti langkah - langkah berikut untuk menggunakan aplikasi JobAble',
              isExpanded: true,
              children: [
                _buildStepItem('1.', 'Login atau daftar akun'),
                _buildStepItem('2.', 'Lengkapi profil anda'),
                _buildStepItem('3.', 'Cari lowongan pekerjaan'),
                _buildStepItem('4.', 'Kirim lamaran pekerjaan'),
              ],
            ),
            const SizedBox(height: 16),
            _buildHelpCard(
              icon: Icons.description_outlined,
              title: 'Cara Melamar Pekerjaan',
              subtitle: 'Pelajari langkah-langkah melamar pekerjaan melalui aplikasi',
              children: [
                _buildStepItem('1.', 'Buka tab Beranda atau Cari Lowongan'),
                _buildStepItem('2.', 'Pilih lowongan yang sesuai minat Anda'),
                _buildStepItem('3.', 'Klik tombol "Lamar Sekarang"'),
                _buildStepItem('4.', 'Tunggu konfirmasi dari pihak perusahaan'),
              ],
            ),
            const SizedBox(height: 16),
            _buildHelpCard(
              icon: Icons.accessibility_new_outlined,
              title: 'Pengaturan Aksesibilitas',
              subtitle: 'Sesuaikan aplikasi agar lebih mudah digunakan sesuai kebutuhan anda.',
              children: [
                _buildStepItem('•', 'Gunakan fitur Screen Reader untuk tunanetra'),
                _buildStepItem('•', 'Aktifkan High Contrast untuk penglihatan rendah'),
                _buildStepItem('•', 'Sesuaikan ukuran font di Pengaturan Akun'),
              ],
            ),
            const SizedBox(height: 16),
            _buildHelpCard(
              icon: Icons.phone_in_talk_outlined,
              title: 'Hubungi Kami',
              subtitle: 'Butuh bantuan lebih lanjut? Hubungi tim kami melalui kontak berikut.',
              children: [
                _buildStepItem('Email', 'azkha.nazzala.tif24@polban.ac.id'),
                _buildStepItem('WA', '082119765944'),
              ],
            ),
            const SizedBox(height: 32),
            
            // Footer Contact Section (New)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0E7FF)),
              ),
              child: Column(
                children: [
                   const Text(
                    'Masih butuh bantuan?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tim kami siap membantu Anda kapan saja melalui email atau formulir kontak.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _launchEmail,
                          icon: const Icon(Icons.email_outlined, size: 18),
                          label: const Text('Email Kami', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryNavy,
                            side: const BorderSide(color: AppColors.primaryNavy),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchWhatsApp,
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Formulir Kontak', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isExpanded = false,
    List<Widget>? children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF), // Soft blue
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryNavy),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.primaryNavy,
          ),
          children: children ?? [],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: 24, bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (number != '4.') // Divider for items except the last one
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Divider(color: Colors.grey.shade200, thickness: 1),
            ),
        ],
      ),
    );
  }
}
