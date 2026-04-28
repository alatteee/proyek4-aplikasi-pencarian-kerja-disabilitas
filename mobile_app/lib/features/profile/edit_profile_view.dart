import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'profile_controller.dart';
import 'widgets/skill_chip.dart';

class EditProfileView extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final Map<String, dynamic>? userDetails;

  const EditProfileView({super.key, required this.currentUser, this.userDetails});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _namaLengkapController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _deskripsiController;
  final TextEditingController _skillController = TextEditingController();

  String? _jenisKelamin;
  String? _jenisDisabilitas;
  List<String> _skills = [];
  String? _cvFileName;
  bool _isLoading = false;

  final List<String> _kelaminOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _disabilitasOptions = [
    'Tunanetra',
    'Tunarungu',
    'Tunadaksa',
    'Tunawicara',
    'Disabilitas Intelektual',
    'Disabilitas Mental',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _namaLengkapController = TextEditingController(text: widget.userDetails?['nama_lengkap'] ?? widget.currentUser['username']);
    _emailController = TextEditingController(text: widget.userDetails?['email'] ?? widget.currentUser['email']);
    _phoneController = TextEditingController(text: widget.userDetails?['phone'] ?? widget.currentUser['phone']);
    _deskripsiController = TextEditingController(text: widget.userDetails?['deskripsi_disabilitas'] ?? '');
    
    // Load dropdowns if they exist in options
    final jk = widget.userDetails?['jenis_kelamin'];
    if (_kelaminOptions.contains(jk)) _jenisKelamin = jk;
    
    final jd = widget.userDetails?['jenis_disabilitas'];
    if (_disabilitasOptions.contains(jd)) _jenisDisabilitas = jd;
    
    _cvFileName = widget.userDetails?['cv_filename'];
    
    final skillsData = widget.userDetails?['skills'];
    if (skillsData != null && skillsData is List) {
      _skills = skillsData.map((e) => e.toString()).toList();
    }
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deskripsiController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
      });
    }
    _skillController.clear();
  }

  void _pickCV() {
    // Fungsi ini dinonaktifkan sementara untuk menghindari error kompilasi
    // Kita buat simulasi tampilan saja dulu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur pilih file akan segera aktif')),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_jenisKelamin == null || _jenisDisabilitas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih Jenis Kelamin dan Jenis Disabilitas')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final data = {
      'user_id': widget.currentUser['_id'],
      'nama_lengkap': _namaLengkapController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'jenis_kelamin': _jenisKelamin,
      'jenis_disabilitas': _jenisDisabilitas,
      'deskripsi_disabilitas': _deskripsiController.text.trim(),
      'skills': _skills,
      'cv_filename': _cvFileName,
    };

    final success = await ProfileController.createOrUpdateProfile(data);
    setState(() { _isLoading = false; });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan profil'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Nama Lengkap', _namaLengkapController, validator: (v) => v!.isEmpty ? 'Tidak boleh kosong' : null),
              _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v == null || v.isEmpty) return 'Tidak boleh kosong';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              }),
              _buildTextField('No. Handphone', _phoneController, keyboardType: TextInputType.phone, validator: (v) {
                if (v == null || v.isEmpty) return 'Tidak boleh kosong';
                if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Hanya boleh berisi angka';
                if (v.length < 10) return 'Minimal 10 digit';
                return null;
              }),
              
              _buildDropdown('Jenis Kelamin', _kelaminOptions, _jenisKelamin, (v) => setState(() => _jenisKelamin = v)),
              _buildDropdown('Jenis Disabilitas', _disabilitasOptions, _jenisDisabilitas, (v) => setState(() => _jenisDisabilitas = v)),
              
              _buildTextField('Deskripsi Disabilitas', _deskripsiController, maxLines: 3),
              
              const SizedBox(height: 16),
              const Text('Kemampuan (Skills)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillController,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan skill (mis: Microsoft Word)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) => SkillChip(
                  label: skill,
                  onDeleted: () {
                    setState(() => _skills.remove(skill));
                  },
                )).toList(),
              ),

              const SizedBox(height: 24),
              const Text('CV', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickCV,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryNavy.withOpacity(0.2),
                      style: BorderStyle.solid, // Note: standard Flutter doesn't support dashed natively without custom painter, using solid with low opacity for similar feel
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.primaryNavy),
                      const SizedBox(height: 12),
                      Text(
                        _cvFileName ?? 'Upload / Ganti CV',
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (_cvFileName != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Klik untuk mengganti file',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Profil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryNavy)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              label, 
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primaryNavy,
                letterSpacing: 0.5,
              )
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true, // Memastikan text tidak terpotong
              items: options.map((o) => DropdownMenuItem(
                value: o, 
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    o, 
                    style: const TextStyle(
                      fontSize: 15, 
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                )
              )).toList(),
              onChanged: onChanged,
              validator: (v) => v == null ? 'Harap pilih $label' : null,
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.expand_more_rounded, 
                  color: AppColors.primaryNavy.withOpacity(0.8),
                  size: 28,
                ),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 16,
              menuMaxHeight: 350,
              // Memberikan jarak horizontal antara menu popup dengan tepi layar
              padding: const EdgeInsets.symmetric(horizontal: 12), 
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 12, right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    label.contains('Kelamin') ? Icons.wc_rounded : Icons.accessibility_new_rounded,
                    color: AppColors.primaryNavy,
                    size: 18,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.8),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
