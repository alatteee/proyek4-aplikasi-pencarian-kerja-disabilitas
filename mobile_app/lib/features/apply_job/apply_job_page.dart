import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mongo_service.dart';
import 'application_success_page.dart';

class ApplyJobPage extends StatefulWidget {
  final Map<String, dynamic> job;
  final Map<String, dynamic> currentUser;
  final Map<String, dynamic> userDetails;

  const ApplyJobPage({
    super.key,
    required this.job,
    this.currentUser = const {},
    this.userDetails = const {},
  });

  @override
  State<ApplyJobPage> createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;
  int _messageLength = 0;
  String? _selectedCvName;
  String? _selectedCvPath;
  int? _selectedCvSize;

  static const int _maxMessageLength = 100;
  static const int _maxCvSizeBytes = 10 * 1024 * 1024;

  @override
  void initState() {
    super.initState();

    _messageController.addListener(() {
      setState(() {
        _messageLength = _messageController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String get _jobId => MongoService.getMongoId(widget.job['_id']);

  String get _userId {
    return widget.currentUser['_id']?.toString() ??
        widget.currentUser['id']?.toString() ??
        widget.currentUser['user_id']?.toString() ??
        widget.currentUser['email']?.toString() ??
        '';
  }

  String get _fullName {
    return widget.userDetails['nama_lengkap']?.toString() ??
        widget.currentUser['nama_lengkap']?.toString() ??
        '';
  }

  String get _email {
    return widget.userDetails['email']?.toString() ??
        widget.currentUser['email']?.toString() ??
        '-';
  }

  String get _phone {
    return widget.userDetails['phone']?.toString() ??
        widget.userDetails['no_hp']?.toString() ??
        widget.currentUser['phone']?.toString() ??
        widget.currentUser['no_hp']?.toString() ??
        '-';
  }

  String get _jobTitle => widget.job['title']?.toString() ?? '-';
  String get _companyName => widget.job['company_name']?.toString() ?? '-';
  String get _location => widget.job['location']?.toString() ?? '-';
  String get _jobType => widget.job['job_type']?.toString() ?? '-';

  String _formatFileSize(int? sizeInBytes) {
    if (sizeInBytes == null || sizeInBytes <= 0) return '-';

    final sizeInKb = sizeInBytes / 1024;
    if (sizeInKb < 1024) {
      return '${sizeInKb.toStringAsFixed(0)} Kb';
    }

    final sizeInMb = sizeInKb / 1024;
    return '${sizeInMb.toStringAsFixed(1)} MB';
  }

  Future<void> _pickCvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final fileSize = file.size;

      if (fileSize > _maxCvSizeBytes) {
        _showCustomSnackBar(
          'Ukuran CV maksimal 10 MB',
          icon: Icons.error_outline,
        );
        return;
      }

      setState(() {
        _selectedCvName = file.name;
        _selectedCvPath = file.path;
        _selectedCvSize = fileSize;
      });
    } catch (e) {
      _showCustomSnackBar(
        'Gagal memilih file CV',
        icon: Icons.error_outline,
      );
    }
  }

  void _showCustomSnackBar(String message, {IconData icon = Icons.info_outline}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryNavy,
        elevation: 8,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (_isSubmitting) return;

    final message = _messageController.text.trim();

    if (_userId.isEmpty || _jobId.isEmpty) {
      _showCustomSnackBar(
        'Data pengguna atau lowongan tidak valid',
        icon: Icons.error_outline,
      );
      return;
    }

    if (_fullName.trim().isEmpty || _email.trim().isEmpty || _phone.trim().isEmpty) {
      _showCustomSnackBar(
        'Data diri belum lengkap',
        icon: Icons.error_outline,
      );
      return;
    }

    if (message.length > _maxMessageLength) {
      _showCustomSnackBar(
        'Pesan maksimal 100 karakter',
        icon: Icons.error_outline,
      );
      return;
    }

    if (_selectedCvName == null || _selectedCvName!.isEmpty) {
      _showCustomSnackBar(
        'Silakan pilih file CV terlebih dahulu',
        icon: Icons.error_outline,
      );
      return;
    }

    if ((_selectedCvSize ?? 0) > _maxCvSizeBytes) {
      _showCustomSnackBar(
        'Ukuran CV maksimal 10 MB',
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final alreadyApplied = await MongoService.hasAppliedJob(
      userId: _userId,
      jobId: _jobId,
    );

    if (!mounted) return;

    if (alreadyApplied) {
      setState(() {
        _isSubmitting = false;
      });
      _showCustomSnackBar(
        'Kamu sudah pernah melamar lowongan ini',
        icon: Icons.info_outline,
      );
      return;
    }

    final success = await MongoService.submitJobApplication(
      applicationData: {
        'user_id': _userId,
        'job_id': _jobId,
        'job_title': _jobTitle,
        'company_name': _companyName,
        'full_name': _fullName,
        'email': _email,
        'phone': _phone,
        'cv_file_name': _selectedCvName ?? '',
        'cv_file_size': _selectedCvSize ?? 0,
        'cv_file_path': _selectedCvPath ?? '',
        'message': message,
        'status': 'pending',
        'sync_status': 'synced',
        'created_at': DateTime.now().toUtc(),
      },
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicationSuccessPage(currentUser: widget.currentUser),
        ),
      );
    } else {
      _showCustomSnackBar(
        'Lamaran gagal dikirim',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: _Header(
                title: 'Lamar Sekarang',
                onBack: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _JobSummaryCard(
                      title: _jobTitle,
                      company: _companyName,
                      location: _location,
                      jobType: _jobType,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Data Diri',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Data Diambil dari profil kamu. Pastikan sudah benar.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InfoField(
                      icon: Icons.person,
                      label: 'Nama Lengkap',
                      value: _fullName.isEmpty ? '-' : _fullName,
                    ),
                    const SizedBox(height: 13),
                    _InfoField(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _email.isEmpty ? '-' : _email,
                    ),
                    const SizedBox(height: 13),
                    _InfoField(
                      icon: Icons.phone,
                      label: 'No. Handphone',
                      value: _phone.isEmpty ? '-' : _phone,
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'CV / Resume',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upload atau pilih CV terbaru kamu',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _CvBox(
                      fileName: _selectedCvName,
                      fileSizeText: _selectedCvSize == null
                          ? null
                          : _formatFileSize(_selectedCvSize),
                      onPickFile: _pickCvFile,
                    ),
                    const SizedBox(height: 9),
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 15, color: AppColors.textGray),
                        SizedBox(width: 4),
                        Text(
                          'Format File : PDF (Maks 10 MB)',
                          style: TextStyle(fontSize: 11, color: AppColors.textGray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Pesan untuk Perusahaan (Opsional)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tulis pesan singkat untuk memperkenalkan dirimu',
                      style: TextStyle(fontSize: 11, color: AppColors.textGray),
                    ),
                    const SizedBox(height: 12),
                    _MessageBox(
                      controller: _messageController,
                      maxLength: _maxMessageLength,
                      currentLength: _messageLength,
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitApplication,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send_outlined, color: Colors.white, size: 24),
                        label: Text(
                          _isSubmitting ? 'Mengirim...' : 'Kirim Lamaran',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          disabledBackgroundColor: AppColors.primaryNavy.withOpacity(0.65),
                          elevation: 4,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryNavy,
            size: 28,
          ),
        ),
        const SizedBox(width: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
      ],
    );
  }
}

class _JobSummaryCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String jobType;

  const _JobSummaryCard({
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.headset_mic,
              color: AppColors.primaryNavy,
              size: 40,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 15, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location,
                        style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.work, size: 15, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        jobType,
                        style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryNavy, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryNavy, size: 25),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CvBox extends StatelessWidget {
  final String? fileName;
  final String? fileSizeText;
  final VoidCallback onPickFile;

  const _CvBox({
    required this.fileName,
    required this.fileSizeText,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null && fileName!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPickFile,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primaryNavy,
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFile ? fileName! : 'Pilih CV / Resume',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasFile ? 'PDF • ${fileSizeText ?? '-'}' : 'PDF • Maks 10 MB',
                      style: const TextStyle(fontSize: 11, color: AppColors.textGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: onPickFile,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    foregroundColor: AppColors.primaryNavy,
                    side: const BorderSide(color: AppColors.primaryNavy, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    hasFile ? 'Ganti' : 'Pilih',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final int currentLength;

  const _MessageBox({
    required this.controller,
    required this.maxLength,
    required this.currentLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 93,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryNavy, width: 1),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: maxLength,
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'Tulis pesan kamu disini...',
              hintStyle: TextStyle(color: AppColors.textGray, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 13, 16, 24),
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.primaryNavy),
          ),
          Positioned(
            right: 14,
            bottom: 8,
            child: Text(
              '$currentLength/$maxLength',
              style: const TextStyle(fontSize: 11, color: AppColors.textGray),
            ),
          ),
        ],
      ),
    );
  }
}
