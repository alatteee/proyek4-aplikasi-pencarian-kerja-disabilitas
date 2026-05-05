import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import 'company_edit_profile_page.dart';

class CompanyProfileDetailPage extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const CompanyProfileDetailPage({
    super.key,
    required this.companyData,
  });

  @override
  State<CompanyProfileDetailPage> createState() =>
      _CompanyProfileDetailPageState();
}

class _CompanyProfileDetailPageState extends State<CompanyProfileDetailPage> {
  late Map<String, dynamic> companyData;
  bool isLoading = false;

  static const Color navy = Color(0xFF0B1B55);
  static const Color textDark = Color(0xFF07122F);
  static const Color hintText = Color(0xFF5B6475);
  static const Color inputFill = Color(0xFFF3F5FC);

  @override
  void initState() {
    super.initState();
    companyData = Map<String, dynamic>.from(widget.companyData);
  }

  Future<void> _refreshCompanyData() async {
    final companyName = companyData['company_name']?.toString() ?? '';

    if (companyName.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final latestData = await MongoService.getCompanyByName(companyName);

    if (!mounted) return;

    setState(() {
      if (latestData != null) {
        companyData = latestData;
      }

      isLoading = false;
    });
  }

  Future<void> _goToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyEditProfilePage(
          companyData: companyData,
        ),
      ),
    );

    if (result == true) {
      await _refreshCompanyData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = companyData['company_name']?.toString() ?? '-';
    final field = companyData['field']?.toString() ?? 'Perusahaan';
    final email = companyData['email']?.toString() ?? '-';
    final phone = companyData['phone']?.toString() ?? '-';
    final address = companyData['address']?.toString() ?? '-';
    final description = companyData['description']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: navy,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(23, 24, 23, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 24),

                    _buildCompanyCard(
                      companyName: companyName,
                      field: field,
                    ),

                    const SizedBox(height: 28),

                    _buildInfoGroup(
                      label: 'Email',
                      value: email,
                    ),

                    const SizedBox(height: 22),

                    _buildInfoGroup(
                      label: 'No. Telepon',
                      value: phone,
                    ),

                    const SizedBox(height: 22),

                    _buildInfoGroup(
                      label: 'Alamat',
                      value: address,
                    ),

                    const SizedBox(height: 22),

                    _buildInfoGroup(
                      label: 'Deskripsi Perusahaan',
                      value: description,
                      minHeight: 92,
                    ),

                    const SizedBox(height: 42),

                    _buildEditButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context, true),
          child: const Icon(
            Icons.arrow_back,
            color: navy,
            size: 32,
          ),
        ),

        const SizedBox(width: 22),

        const Expanded(
          child: Text(
            'Profil Perusahaan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard({
    required String companyName,
    required String field,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 26,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 13,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.apartment_rounded,
            color: navy,
            size: 46,
          ),

          const SizedBox(height: 13),

          Text(
            companyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            field,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: hintText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGroup({
    required String label,
    required String value,
    double minHeight = 64,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: minHeight,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 22,
            vertical: minHeight > 70 ? 18 : 0,
          ),
          decoration: BoxDecoration(
            color: inputFill,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: minHeight > 70 ? 4 : 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: hintText,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _goToEditProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_rounded,
              size: 25,
              color: Colors.white,
            ),
            SizedBox(width: 18),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}