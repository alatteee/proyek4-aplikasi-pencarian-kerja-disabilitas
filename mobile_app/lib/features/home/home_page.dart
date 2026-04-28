import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Halo, . Selamat Pagi!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Search Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Lowongan Pekerjaan...',
                    hintStyle: TextStyle(color: AppColors.textGray),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Kategori Buttons
              Row(
                children: const [
                   Expanded(child: _CategoryButton('Semua', true)),
                   SizedBox(width: 12),
                   Expanded(child: _CategoryButton('Teknologi', false)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                   Expanded(child: _CategoryButton('Marketing', false)),
                   SizedBox(width: 12),
                   Expanded(child: _CategoryButton('Admin', false)),
                ],
              ),
              const SizedBox(height: 32),
              
              // Section Title
              const Text(
                'Lowongan Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Job Card 1
              const _JobCard(
                title: 'Customer Service',
                company: 'PT Maju Bersama',
                location: 'Bandung',
                type: 'Full Time',
                desc: 'Melayani pelanggan melalui telepon, chat, atau email serta memberikan solusi terbaik untuk setiap kebutuhan.',
                isSaved: true,
              ),
              const SizedBox(height: 16),
              // Job Card 2
              const _JobCard(
                title: 'Content Writer',
                company: 'PT Sejahtera Jaya',
                location: 'Bandung',
                type: 'Part Time',
                desc: 'Membuat dan mengembangkan konten tulisan untuk media digital seperti artikel, website, dan sosial media.',
                isSaved: false,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(icon: Icon(Icons.cases_outlined), label: 'Lamaran'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
            ],
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
        border: Border.all(
          color: isSelected ? AppColors.primaryNavy : Colors.grey.shade400,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
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

  const _JobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.desc,
    required this.isSaved,
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            company,
            style: const TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
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
          Text(
            desc,
            style: const TextStyle(color: AppColors.textGray, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
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