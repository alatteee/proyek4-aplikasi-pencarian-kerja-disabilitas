import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';

class CompanyApplicantDetailPage extends StatefulWidget {
  final Map<String, dynamic> applicant;
  final Map<String, dynamic> job;

  const CompanyApplicantDetailPage({
    super.key,
    required this.applicant,
    required this.job,
  });

  @override
  State<CompanyApplicantDetailPage> createState() => _CompanyApplicantDetailPageState();
}

class _CompanyApplicantDetailPageState extends State<CompanyApplicantDetailPage> {
  Map<String, dynamic>? user;
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = widget.applicant['user_id']?.toString() ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final results = await Future.wait([
        MongoService.getUserById(widget.applicant['user_id']),
        MongoService.getUserDetailsByUserId(widget.applicant['user_id']),
      ]);

      if (!mounted) return;

      final loadedUser = results[0] as Map<String, dynamic>?;
      var loadedUserDetails = results[1] as Map<String, dynamic>?;

      if (loadedUserDetails == null) {
        final applicantEmail = widget.applicant['email']?.toString() ?? '';
        if (applicantEmail.isNotEmpty) {
          loadedUserDetails = await MongoService.getUserDetailsByEmail(applicantEmail);
        }
      }

      if (!mounted) return;

      setState(() {
        user = loadedUser;
        userDetails = loadedUserDetails;
        isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _stringValue(dynamic value) => value?.toString() ?? '';

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
    final applicationId = MongoService.getMongoId(widget.applicant['_id']);

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
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _stringValue(userDetails?['nama_lengkap']).isNotEmpty
        ? _stringValue(userDetails?['nama_lengkap'])
        : _stringValue(widget.applicant['full_name']).isNotEmpty
            ? _stringValue(widget.applicant['full_name'])
            : _stringValue(user?['username']).isNotEmpty
                ? _stringValue(user?['username'])
                : 'Pelamar';

    final email = _stringValue(user?['email']).isNotEmpty
        ? _stringValue(user?['email'])
        : _stringValue(widget.applicant['email']);

    final phone = _stringValue(userDetails?['phone']).isNotEmpty
        ? _stringValue(userDetails?['phone'])
        : _stringValue(user?['phone']).isNotEmpty
            ? _stringValue(user?['phone'])
            : _stringValue(widget.applicant['phone']);

    final location = _stringValue(widget.applicant['location']).isNotEmpty
        ? _stringValue(widget.applicant['location'])
        : _stringValue(widget.job['location']).isNotEmpty
            ? _stringValue(widget.job['location'])
            : '-';

    final status = _stringValue(widget.applicant['status']).isNotEmpty
        ? _stringValue(widget.applicant['status'])
        : 'pending';

    final jobTitle = _stringValue(widget.applicant['job_title']).isNotEmpty
        ? _stringValue(widget.applicant['job_title'])
        : _stringValue(widget.job['title']).isNotEmpty
            ? _stringValue(widget.job['title'])
            : '-';

    final birthDateValue = userDetails?['tanggal_lahir'] ?? userDetails?['birth_date'] ?? widget.applicant['birth_date'] ?? widget.applicant['tanggal_lahir'];
    final birthDate = birthDateValue != null && _stringValue(birthDateValue).isNotEmpty
        ? _formatDateShort(birthDateValue)
        : '-';

    final gender = _stringValue(userDetails?['jenis_kelamin']).isNotEmpty
        ? _stringValue(userDetails?['jenis_kelamin'])
        : _stringValue(widget.applicant['gender']).isNotEmpty
            ? _stringValue(widget.applicant['gender'])
            : _stringValue(widget.applicant['jenis_kelamin']);

    final disability = _stringValue(userDetails?['jenis_disabilitas']).isNotEmpty
        ? _stringValue(userDetails?['jenis_disabilitas'])
        : _stringValue(userDetails?['disabilitas']).isNotEmpty
            ? _stringValue(userDetails?['disabilitas'])
            : _stringValue(widget.applicant['disability']).isNotEmpty
                ? _stringValue(widget.applicant['disability'])
                : _stringValue(widget.applicant['disabilitas']);

    final skills = _toStringList(userDetails?['skills']).isNotEmpty
        ? _toStringList(userDetails?['skills'])
        : _toStringList(widget.applicant['skills']);

    final cvFileName = _stringValue(widget.applicant['cv_file_name']).isNotEmpty
        ? _stringValue(widget.applicant['cv_file_name'])
        : _stringValue(widget.applicant['cv_name']);

    final coverLetterFile = _stringValue(widget.applicant['cover_letter_file']).isNotEmpty
        ? _stringValue(widget.applicant['cover_letter_file'])
        : _stringValue(widget.applicant['cover_letter_name']);

    final createdAt = widget.applicant['created_at'];
    final sentDate = _formatDateShort(createdAt);
    final processedDate = widget.applicant['processed_at'] != null
        ? _formatDateShort(widget.applicant['processed_at'])
        : '-';
    final acceptedDate = widget.applicant['accepted_at'] != null
        ? _formatDateShort(widget.applicant['accepted_at'])
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
          _buildProfileAvatar(name),
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

  Widget _buildProfileAvatar(String name) {
    final profilePhoto = _stringValue(userDetails?['profile_photo']);
    if (profilePhoto.isNotEmpty) {
      try {
        final ImageProvider<Object> imageProvider = profilePhoto.startsWith('/')
            ? FileImage(File(profilePhoto)) as ImageProvider<Object>
            : MemoryImage(base64Decode(profilePhoto)) as ImageProvider<Object>;

        return CircleAvatar(
          radius: 34,
          backgroundColor: lightBlue,
          backgroundImage: imageProvider,
        );
      } catch (_) {
        // Fall back to initials when the photo is not valid.
      }
    }

    return CircleAvatar(
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
    final documents = <String>[];
    if (cvFileName.isNotEmpty) documents.add(cvFileName);
    if (coverLetterFile.isNotEmpty) documents.add(coverLetterFile);

    if (documents.isEmpty) {
      return _sectionCard(
        title: 'Dokumen',
        child: const Text(
          'Tidak ada dokumen',
          style: TextStyle(color: textGrey),
        ),
      );
    }

    return _sectionCard(
      title: 'Dokumen',
      child: Column(
        children: [
          for (int i = 0; i < documents.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i < documents.length - 1 ? 14 : 0),
              child: _documentRow(
                fileName: documents[i],
                uploadedDate: uploadedDate,
                onTap: () {},
              ),
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