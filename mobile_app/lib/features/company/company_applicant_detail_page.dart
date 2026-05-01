import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';

class CompanyApplicantDetailPage extends StatelessWidget {
  final Map<String, dynamic> applicant;
  final Map<String, dynamic> job;

  const CompanyApplicantDetailPage({
    super.key,
    required this.applicant,
    required this.job,
  });

  static const Color navy = Color(0xFF0D1B55);
  static const Color textGrey = Color(0xFF4A5870);
  static const Color lightBlue = Color(0xFFEAF0FF);
  static const Color chipBlue = Color(0xFF91B4FF);

  static const Color greenBg = Color(0xFFD4F0DD);
  static const Color greenText = Color(0xFF18A64A);
  static const Color orangeBg = Color(0xFFFFE4B8);
  static const Color orangeText = Color(0xFFF59E0B);
  static const Color greyBg = Color(0xFFE5E5E5);
  static const Color greyText = Color(0xFF5B6472);

  String _getInitials(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return '?';

    final parts = cleanName.split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) return '-';

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateShort(dynamic value) {
    if (value == null) return '-';

    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) return '-';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'diterima':
      case 'lolos':
        return 'Lolos';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      case 'pending':
      case 'reviewed':
      case 'diproses':
      default:
        return 'Diproses';
    }
  }

  bool _isAccepted(String status) {
    final value = status.toLowerCase();
    return value == 'accepted' || value == 'diterima' || value == 'lolos';
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value];
    }

    return [];
  }

  Future<void> _updateApplicantStatus({
    required BuildContext context,
    required String status,
  }) async {
    final applicationId = MongoService.getMongoId(applicant['_id']);

    final success = await MongoService.updateApplicationStatus(
      applicationId: applicationId,
      status: status,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'accepted'
                ? 'Pelamar berhasil diloloskan'
                : 'Status pelamar berhasil diperbarui',
          ),
        ),
      );

      Navigator.pop(context, status);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui status pelamar'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = applicant['full_name']?.toString() ?? 'Albert Florest';
    final email = applicant['email']?.toString() ?? 'user123@gmail.com';
    final phone = applicant['phone']?.toString() ?? '08123456789';
    final location =
        applicant['location']?.toString() ?? job['location']?.toString() ?? 'Bandung, Jawa Barat';

    final status = applicant['status']?.toString() ?? 'pending';
    final jobTitle =
        applicant['job_title']?.toString() ?? job['title']?.toString() ?? 'Customer Service';

    final birthDate =
        applicant['birth_date']?.toString() ?? applicant['tanggal_lahir']?.toString() ?? '29 Februari 2000';
    final gender =
        applicant['gender']?.toString() ?? applicant['jenis_kelamin']?.toString() ?? 'Laki-laki';
    final disability =
        applicant['disability']?.toString() ?? applicant['disabilitas']?.toString() ?? 'Tunarungu';

    final skills = _toStringList(applicant['skills']).isEmpty
        ? ['Komunikasi', 'Microsoft Office']
        : _toStringList(applicant['skills']);

    final cvFileName = applicant['cv_file_name']?.toString() ?? 'CV_Albert_Florest.pdf';
    final coverLetterFile =
        applicant['cover_letter_file']?.toString() ?? 'Surat_Lamaran.pdf';

    final createdAt = applicant['created_at'];
    final sentDate = _formatDateShort(createdAt);
    final processedDate = applicant['processed_at'] != null
        ? _formatDateShort(applicant['processed_at'])
        : '14 Apr 2026';
    final acceptedDate = applicant['accepted_at'] != null
        ? _formatDateShort(applicant['accepted_at'])
        : '-';

    final isAccepted = _isAccepted(status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildProfileCard(
              name: name,
              email: email,
              phone: phone,
              location: location,
              jobTitle: jobTitle,
              status: status,
              createdAt: createdAt,
            ),
            const SizedBox(height: 18),
            _buildStatusProgressCard(
              sentDate: sentDate,
              processedDate: processedDate,
              acceptedDate: acceptedDate,
              isAccepted: isAccepted,
            ),
            const SizedBox(height: 18),
            _buildAboutCard(
              name: name,
              birthDate: birthDate,
              gender: gender,
              disability: disability,
            ),
            const SizedBox(height: 18),
            _buildSkillsCard(skills),
            const SizedBox(height: 18),
            _buildDocumentsCard(
              cvFileName: cvFileName,
              coverLetterFile: coverLetterFile,
              uploadedDate: _formatDateShort(createdAt),
            ),
            const SizedBox(height: 24),
            if (!isAccepted)
              _primaryButton(
                icon: Icons.check_rounded,
                text: 'Loloskan Pelamar',
                color: greenText,
                onTap: () {
                  _updateApplicantStatus(
                    context: context,
                    status: 'accepted',
                  );
                },
              ),
            if (!isAccepted) const SizedBox(height: 12),
            _outlineButton(
              icon: Icons.hourglass_bottom_rounded,
              text: 'Tandai Diproses',
              color: orangeText,
              onTap: () {
                _updateApplicantStatus(
                  context: context,
                  status: 'pending',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            size: 34,
            color: navy,
          ),
        ),
        const SizedBox(width: 18),
        const Text(
          'Detail Pelamar',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String email,
    required String phone,
    required String location,
    required String jobTitle,
    required String status,
    required dynamic createdAt,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: lightBlue,
            child: Text(
              _getInitials(name),
              style: const TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Melamar sebagai ',
                        style: TextStyle(
                          fontSize: 14,
                          color: textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: jobTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _smallInfo(Icons.email_rounded, email),
                const SizedBox(height: 8),
                _smallInfo(Icons.phone_rounded, phone),
                const SizedBox(height: 8),
                _smallInfo(Icons.location_on_rounded, location),
                const SizedBox(height: 8),
                _smallInfo(
                  Icons.calendar_month_rounded,
                  'Melamar pada ${_formatDate(createdAt)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgressCard({
    required String sentDate,
    required String processedDate,
    required String acceptedDate,
    required bool isAccepted,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Lamaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _stepIcon(active: true),
              Expanded(
                child: Container(
                  height: 3,
                  color: greenText,
                ),
              ),
              _stepIcon(active: true),
              Expanded(
                child: Container(
                  height: 3,
                  color: isAccepted ? greenText : textGrey,
                ),
              ),
              _stepIcon(active: isAccepted),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _stepText(
                  title: 'Dikirim',
                  date: sentDate,
                  align: TextAlign.left,
                ),
              ),
              Expanded(
                child: _stepText(
                  title: 'Diproses',
                  date: processedDate,
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                child: _stepText(
                  title: 'Lolos Berkas',
                  date: acceptedDate,
                  align: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepIcon({required bool active}) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: active ? greenBg : greyBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? greenText : greyText,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 24,
        color: active ? greenText : greyText,
      ),
    );
  }

  Widget _stepText({
    required String title,
    required String date,
    required TextAlign align,
  }) {
    return Text(
      '$title\n$date',
      textAlign: align,
      style: const TextStyle(
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: textGrey,
      ),
    );
  }

  Widget _buildAboutCard({
    required String name,
    required String birthDate,
    required String gender,
    required String disability,
  }) {
    return _sectionCard(
      title: 'Tentang Pelamar',
      child: Column(
        children: [
          _profileInfoRow(
            icon: Icons.person_rounded,
            label: 'Nama Lengkap',
            value: name,
          ),
          _profileInfoRow(
            icon: Icons.cake_rounded,
            label: 'Tanggal Lahir',
            value: birthDate,
          ),
          _profileInfoRow(
            icon: Icons.wc_rounded,
            label: 'Jenis Kelamin',
            value: gender,
          ),
          _profileInfoRow(
            icon: Icons.accessibility_new_rounded,
            label: 'Disabilitas',
            value: disability,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(List<String> skills) {
    return _sectionCard(
      title: 'Keahlian Pelamar',
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: skills.map((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: BoxDecoration(
              color: chipBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              skill,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentsCard({
    required String cvFileName,
    required String coverLetterFile,
    required String uploadedDate,
  }) {
    return _sectionCard(
      title: 'Dokumen',
      child: Column(
        children: [
          _documentRow(
            fileName: cvFileName,
            uploadedDate: uploadedDate,
            onTap: () {},
          ),
          const SizedBox(height: 14),
          _documentRow(
            fileName: coverLetterFile,
            uploadedDate: uploadedDate,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _documentRow({
    required String fileName,
    required String uploadedDate,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_rounded,
            color: navy,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: navy,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Diunggah $uploadedDate',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 88,
          height: 38,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
            label: const Text('Lihat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: navy,
              side: BorderSide(color: Colors.grey.shade500, width: 1.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: textGrey),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textGrey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17, color: textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final isAccepted = _isAccepted(status);

    return Container(
      width: 90,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isAccepted ? greenBg : orangeBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isAccepted ? greenText : orangeText,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24, color: color),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.14),
          blurRadius: 11,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}