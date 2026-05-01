import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import 'company_applicant_detail_page.dart';

class CompanyGlobalApplicantsPage extends StatefulWidget {
  final List<Map<String, dynamic>> applicants;
  final List<Map<String, dynamic>> jobs;

  const CompanyGlobalApplicantsPage({
    super.key,
    required this.applicants,
    required this.jobs,
  });

  @override
  State<CompanyGlobalApplicantsPage> createState() =>
      _CompanyGlobalApplicantsPageState();
}

class _CompanyGlobalApplicantsPageState
    extends State<CompanyGlobalApplicantsPage> {
  static const Color navy = Color(0xFF0D1B55);
  static const Color textGrey = Color(0xFF4A5870);
  static const Color lightBlue = Color(0xFFEAF0FF);

  String selectedFilter = 'Semua';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get filteredApplicants {
    return widget.applicants.where((applicant) {
      final name = applicant['full_name']?.toString().toLowerCase() ?? '';
      final jobTitle = applicant['job_title']?.toString().toLowerCase() ?? '';
      final status = applicant['status']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();

      final matchSearch = name.contains(query) || jobTitle.contains(query);

      final matchFilter = selectedFilter == 'Semua' ||
          (selectedFilter == 'Diproses' &&
              (status == 'pending' ||
                  status == 'reviewed' ||
                  status == 'diproses')) ||
          (selectedFilter == 'Lolos Berkas' &&
              (status == 'accepted' ||
                  status == 'diterima' ||
                  status == 'lolos'));

      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _findJobByApplicant(Map<String, dynamic> applicant) {
    final applicantJobId = applicant['job_id']?.toString() ?? '';

    return widget.jobs.firstWhere(
      (job) => MongoService.getMongoId(job['_id']) == applicantJobId,
      orElse: () => {
        'title': applicant['job_title'] ?? '-',
        'company_name': applicant['company_name'] ?? '-',
        'location': applicant['location'] ?? '-',
      },
    );
  }

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

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'diterima':
      case 'lolos':
        return 'Lolos Berkas';
      default:
        return 'Diproses';
    }
  }

  Color _statusBg(String status) {
    return _statusLabel(status) == 'Lolos Berkas'
        ? Colors.green.withOpacity(0.15)
        : Colors.orange.withOpacity(0.15);
  }

  Color _statusText(String status) {
    return _statusLabel(status) == 'Lolos Berkas'
        ? Colors.green
        : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchBox(),
          const SizedBox(height: 18),
          _buildFilterButtons(),
          const SizedBox(height: 24),
          Expanded(
            child: filteredApplicants.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filteredApplicants.length,
                    itemBuilder: (context, index) {
                      return _buildApplicantCard(filteredApplicants[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: const [
        Icon(
          Icons.arrow_back,
          size: 34,
          color: navy,
        ),
        SizedBox(width: 18),
        Text(
          'Pelamar',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontSize: 14,
            color: navy,
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 28,
              color: Colors.black54,
            ),
            hintText: 'Cari Pelamar...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['Semua', 'Diproses', 'Lolos Berkas'];

    return Row(
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: filter == 'Lolos Berkas' ? 0 : 10,
            ),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? navy : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: navy,
                    width: 1.4,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    final job = _findJobByApplicant(applicant);

    final name = applicant['full_name']?.toString() ?? 'Pelamar';
    final jobTitle =
        applicant['job_title']?.toString() ?? job['title']?.toString() ?? '-';
    final status = applicant['status']?.toString() ?? 'pending';
    final date = _formatDate(applicant['created_at']);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyApplicantDetailPage(
              applicant: applicant,
              job: job,
            ),
          ),
        );

        if (result is String && mounted) {
          setState(() {
            applicant['status'] = result;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
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
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    jobTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textGrey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg(status),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: _statusText(status),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 100),
        Icon(
          Icons.groups_outlined,
          size: 64,
          color: textGrey,
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'Belum ada pelamar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
        ),
      ],
    );
  }
}