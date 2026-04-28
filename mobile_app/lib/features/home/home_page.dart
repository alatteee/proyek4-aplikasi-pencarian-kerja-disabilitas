import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_view.dart';
import '../../services/mongo_service.dart';
import '../job_detail/job_detail_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool showSuccessDialog;

  const HomePage({super.key, required this.userData, this.showSuccessDialog = false});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List jobs = [];
  List filteredJobs = [];
  bool isLoading = true;
  String selectedCategory = 'Semua';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessBottomSheet();
      });
    }
    fetchJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchJobs() async {
    setState(() {
      isLoading = true;
    });
    final data = await MongoService.getJobVacancies();
    setState(() {
      jobs = data;
      isLoading = false;
    });
    applyFilters();
  }

  void applyFilters() {
    List result = jobs;
    if (selectedCategory != 'Semua') {
      result = result.where((job) =>
        (job['category'] ?? '').toString().toLowerCase() == selectedCategory.toLowerCase()
      ).toList();
    }
    if (searchQuery.isNotEmpty) {
      result = result.where((job) =>
        (job['title'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
        (job['company_name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    setState(() {
      filteredJobs = result;
    });
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      builder: (BuildContext ctx) {
        return Container(
          height: 440,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.1),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 110,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Login Berhasil !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Got It', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildBeranda(context),
      const Center(child: Text('Halaman Lamaran', style: TextStyle(fontSize: 20, color: AppColors.primaryNavy, fontWeight: FontWeight.bold))),
      _buildProfil(context),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0 ? _buildBerandaAppBar() : _buildOtherAppBar(),
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColors.primaryNavy,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(icon: Icon(Icons.cases_outlined), label: 'Lamaran'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildBerandaAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          children: [
            TextSpan(text: 'Job', style: TextStyle(color: AppColors.primaryNavy)),
            TextSpan(text: 'Able', style: TextStyle(color: AppColors.accentBlue)),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications, color: AppColors.primaryNavy, size: 30),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  AppBar _buildOtherAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
        onPressed: () => setState(() => _selectedIndex = 0), // Kembali ke home (Beranda)
      ),
      title: Text(
        _selectedIndex == 1 ? 'Lamaran Saya' : 'Profil Saya',
        style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: false,
    );
  }

  // --- BERANDA WIDGET ---
  Widget _buildBeranda(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${widget.userData['username'] ?? 'User'}. ${_getGreeting()}!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                searchQuery = value;
                applyFilters();
              },
              decoration: const InputDecoration(
                hintText: 'Cari Lowongan Pekerjaan...',
                hintStyle: TextStyle(color: AppColors.textGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'Semua';
                    });
                    applyFilters();
                  },
                  child: _CategoryButton('Semua', selectedCategory == 'Semua'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'Teknologi';
                    });
                    applyFilters();
                  },
                  child: _CategoryButton('Teknologi', selectedCategory == 'Teknologi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'Marketing';
                    });
                    applyFilters();
                  },
                  child: _CategoryButton('Marketing', selectedCategory == 'Marketing'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'Admin';
                    });
                    applyFilters();
                  },
                  child: _CategoryButton('Admin', selectedCategory == 'Admin'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Lowongan Terbaru',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (filteredJobs.isEmpty)
            const Center(child: Text('Belum ada lowongan'))
          else ...filteredJobs.map((job) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _JobCard(
              title: job['title'] ?? '-',
              company: job['company_name'] ?? '-',
              location: job['location'] ?? '-',
              type: job['job_type'] ?? '-',
              desc: job['description'] ?? '-',
              isSaved: false,
              onDetail: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailPage(job: job),
                  ),
                );
              },
            ),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- PROFIL WIDGET ---
  Widget _buildProfil(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
           // User Profile Header
           Row(
             children: [
               Container(
                 width: 80,
                 height: 80,
                 decoration: BoxDecoration(
                   color: AppColors.accentBlue.withOpacity(0.3),
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: const Icon(Icons.person, size: 50, color: AppColors.primaryNavy),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       widget.userData['username'] ?? 'User',
                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                     ),
                     const SizedBox(height: 2),
                     Text(
                       widget.userData['email'] ?? 'email@domain.com',
                       style: const TextStyle(fontSize: 14, color: AppColors.textGray),
                     ),
                     const SizedBox(height: 14),
                     SizedBox(
                       height: 36,
                       width: 120, // fixed width for button
                       child: OutlinedButton(
                         onPressed: () {},
                         style: OutlinedButton.styleFrom(
                           padding: EdgeInsets.zero,
                           foregroundColor: AppColors.primaryNavy,
                           side: const BorderSide(color: AppColors.primaryNavy),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('Lihat Profil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
           
           const SizedBox(height: 32),
           
           // List Menus
           _ProfileMenuCard(icon: Icons.bookmark, label: 'Lowongan Tersimpan', onTap: () {}),
           _ProfileMenuCard(icon: Icons.accessibility_new, label: 'Pengaturan Aksesibilitas', onTap: () {}),
           _ProfileMenuCard(icon: Icons.settings, label: 'Pengaturan Akun', onTap: () {}),
           _ProfileMenuCard(icon: Icons.help, label: 'Bantuan', onTap: () {}),
           _ProfileMenuCard(icon: Icons.info, label: 'Tentang Aplikasi', onTap: () {}),
           
           // Logout Menu
           _ProfileMenuCard(
             icon: Icons.logout,
             label: 'Logout', 
             onTap: () {
                // Logout action - clear route and move to login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
             },
           ),
           
           const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryNavy, size: 24),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CategoryButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  const _CategoryButton(this.title, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? AppColors.primaryNavy : Colors.grey.shade400,),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String type;
  final String desc;
  final bool isSaved;
  final VoidCallback? onDetail;

  const _JobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.desc,
    required this.isSaved,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(company, style: const TextStyle(color: AppColors.textGray, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.work, size: 16, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(type, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Text(desc, style: const TextStyle(color: AppColors.textGray, fontSize: 12, height: 1.4)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black87),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Lihat Detail', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border, 
                    size: 16, 
                    color: isSaved ? Colors.white : Colors.black87
                  ),
                  label: Flexible(
                    child: Text(
                      isSaved ? 'Lowongan Tersimpan' : 'Simpan Lowongan',
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: FontWeight.w600,
                        color: isSaved ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    elevation: 0,
                    backgroundColor: isSaved ? AppColors.primaryNavy : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSaved ? AppColors.primaryNavy : Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
