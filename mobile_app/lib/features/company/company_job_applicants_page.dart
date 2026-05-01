import 'package:flutter/material.dart';
import 'company_applicant_detail_page.dart';
import '../../services/mongo_service.dart';

class CompanyJobApplicantsPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const CompanyJobApplicantsPage({
    super.key,
    required this.job,
  });

  @override
  State<CompanyJobApplicantsPage> createState() =>
      _CompanyJobApplicantsPageState();
}

class _CompanyJobApplicantsPageState extends State<CompanyJobApplicantsPage> {
  static const Color navy = Color(0xFF0D1B55);
  static const Color textGrey = Color(0xFF4A5870);
  static const Color lightBlue = Color(0xFFEAF0FF);
  static const Color activeGreenBg = Color(0xFFD4F0DD);
  static const Color activeGreenText = Color(0xFF18A64A);
  static const Color orangeBg = Color(0xFFFFE4B8);
  static const Color orangeText = Color(0xFFF59E0B);
  static const Color redBg = Color(0xFFF8D1D3);
  static const Color redText = Color(0xFFE2262C);

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> applicants = [];
  bool isLoading = true;
  String selectedFilter = 'Semua';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicants() async {
    setState(() => isLoading = true);

    final jobId = MongoService.getMongoId(widget.job['_id']);
    final data = await MongoService.getApplicantsByJob(jobId: jobId);

    if (!mounted) return;

    setState(() {
      applicants = data;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredApplicants {
    return applicants.where((applicant) {
      final name = applicant['full_name']?.toString().toLowerCase() ?? '';
      final email = applicant['email']?.toString().toLowerCase() ?? '';
      final status = applicant['status']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();

      final matchSearch = name.contains(query) || email.contains(query);

      final matchFilter = selectedFilter == 'Semua' ||
          (selectedFilter == 'Diproses' &&
              (status == 'pending' ||
                  status == 'reviewed' ||
                  status == 'diproses')) ||
          (selectedFilter == 'Lolos' &&
              (status == 'accepted' ||
                  status == 'diterima' ||
                  status == 'lolos')) ||
          (selectedFilter == 'Ditolak' &&
              (status == 'rejected' ||
                  status == 'ditolak'));

      return matchSearch && matchFilter;
    }).toList();
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

  String _getInitials(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return '?';

    final parts = cleanName.split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'reviewed':
      case 'diproses':
        return 'Diproses';
      case 'accepted':
      case 'diterima':
      case 'lolos':
        return 'Lolos';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Diproses';
    }
  }

  Color _statusBg(String status) {
    final label = _statusLabel(status);

    if (label == 'Lolos') return activeGreenBg;
    if (label == 'Ditolak') return redBg;
    return orangeBg;
  }

  Color _statusText(String status) {
    final label = _statusLabel(status);

    if (label == 'Lolos') return activeGreenText;
    if (label == 'Ditolak') return redText;
    return orangeText;
  }

  @override
  Widget build(BuildContext context) {
    final jobTitle = widget.job['title']?.toString() ?? '-';
    final companyName = widget.job['company_name']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadApplicants,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 22),
                _buildJobSummary(jobTitle, companyName),
                const SizedBox(height: 20),
                _buildSearchBox(),
                const SizedBox(height: 18),
                _buildFilterButtons(),
                const SizedBox(height: 22),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredApplicants.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: filteredApplicants.length,
                              itemBuilder: (context, index) {
                                return _buildApplicantCard(
                                  filteredApplicants[index],
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
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
          'Pelamar Lowongan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
      ],
    );
  }

  Widget _buildJobSummary(String jobTitle, String companyName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: navy,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${applicants.length} pelamar',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(
          fontSize: 14,
          color: navy,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search_rounded,
              size: 28,
              color: textGrey,
            ),
          ),
          hintText: 'Cari pelamar...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: textGrey,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['Semua', 'Diproses', 'Lolos'];

    return Row(
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: filter == 'Lolos' ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? navy : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: navy,
                    width: 1.3,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    filter,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : Colors.black87,
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
    final name = applicant['full_name']?.toString() ?? 'Pelamar';
    final email = applicant['email']?.toString() ?? '-';
    final phone = applicant['phone']?.toString() ?? '-';
    final status = applicant['status']?.toString() ?? 'pending';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyApplicantDetailPage(
              applicant: applicant,
              job: widget.job,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: lightBlue,
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
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
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Melamar ${_formatDate(applicant['created_at'])}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      width: 82,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: _statusText(status),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 90),
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
        SizedBox(height: 8),
        Center(
          child: Text(
            'Pelamar untuk lowongan ini akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textGrey,
            ),
          ),
        ),
      ],
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