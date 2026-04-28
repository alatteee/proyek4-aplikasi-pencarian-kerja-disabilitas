import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mongo_service.dart';

class ApplicationsPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const ApplicationsPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  bool _isLoading = true;
  String _selectedStatus = 'Dikirim';
  List<Map<String, dynamic>> _applications = [];


  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  String get _currentUserId {
    return widget.currentUser['_id']?.toString() ??
        widget.currentUser['id']?.toString() ??
        widget.currentUser['user_id']?.toString() ??
        widget.currentUser['email']?.toString() ??
        '';
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);

    final data = await MongoService.getUserApplications(userId: _currentUserId);

    if (!mounted) return;

    setState(() {
      _applications = data;
      _isLoading = false;
    });
  }

  String _statusToFilter(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'reviewed':
      case 'diproses':
      case 'processed':
        return 'Diproses';
      case 'accepted':
      case 'selesai':
      case 'done':
        return 'Selesai';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      case 'pending':
      case 'dikirim':
      default:
        return 'Dikirim';
    }
  }

  String _formatDate(dynamic value) {
    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else if (value != null) {
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

    final localDate = date.toLocal();
    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}';
  }

  List<Map<String, dynamic>> get _filteredApplications {
    return _applications
        .where((application) => _statusToFilter(application['status']?.toString()) == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _StatusButton('Dikirim', _selectedStatus == 'Dikirim', () => _setStatus('Dikirim'))),
                  const SizedBox(width: 26),
                  Expanded(child: _StatusButton('Diproses', _selectedStatus == 'Diproses', () => _setStatus('Diproses'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatusButton('Selesai', _selectedStatus == 'Selesai', () => _setStatus('Selesai'))),
                  const SizedBox(width: 26),
                  Expanded(child: _StatusButton('Ditolak', _selectedStatus == 'Ditolak', () => _setStatus('Ditolak'))),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadApplications,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(color: AppColors.primaryNavy),
                      ),
                    )
                  else if (_filteredApplications.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Text(
                          'Belum ada lamaran ${_selectedStatus.toLowerCase()}',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._filteredApplications.map((application) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _ApplicationCard(
                          title: application['job_title']?.toString() ?? '-',
                          company: application['company_name']?.toString() ?? '-',
                          statusLabel: _statusToFilter(application['status']?.toString()),
                          dateText: _formatDate(application['created_at']),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _setStatus(String status) {
    setState(() => _selectedStatus = status);
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryNavy, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryNavy,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String title;
  final String company;
  final String statusLabel;
  final String dateText;

  const _ApplicationCard({
    required this.title,
    required this.company,
    required this.statusLabel,
    required this.dateText,
  });

  IconData _getIcon() {
    final lower = title.toLowerCase();
    if (lower.contains('admin')) return Icons.desktop_windows_rounded;
    if (lower.contains('writer') || lower.contains('content')) return Icons.edit_rounded;
    return Icons.headset_mic_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIcon(), color: AppColors.primaryNavy, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '$statusLabel $dateText',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
