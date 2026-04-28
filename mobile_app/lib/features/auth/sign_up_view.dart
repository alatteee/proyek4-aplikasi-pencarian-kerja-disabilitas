import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import 'login_view.dart';
import 'auth_controller.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // Field controller baru
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isJobSeeker = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    // 1. Validasi tidak boleh kosong
    if (username.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Isian tidak boleh ada yang kosong.');
      return;
    }

    // 2. Validasi format Email
    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+").hasMatch(email);
    if (!emailValid) {
      _showError('Format Email tidak valid.');
      return;
    }

    // 3. Validasi Phone (hanya angka & minimal 10 digit)
    final bool phoneValid = RegExp(r'^[0-9]+$').hasMatch(phone);
    if (!phoneValid || phone.length < 10) {
      _showError('Nomor HP harus berupa angka dan minimal 10 digit.');
      return;
    }

    // 4. Validasi password minimal 6 karakter
    if (password.length < 6) {
      _showError('Kata sandi harus memiliki setidaknya 6 karakter.');
      return;
    }

    // 5. Validasi password match
    if (password != confirm) {
      _showError('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() { _isLoading = true; });

    // Panggil Service Signup Controller
    final String role = _isJobSeeker ? 'job_seeker' : 'company';
    final String? resultError = await AuthController.signUp(
      username: username,
      email: email,
      phone: phone,
      password: password,
      role: role
    );

    setState(() { _isLoading = false; });

    if (resultError != null) {
      if (!mounted) return;
      _showError(resultError);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil! Silakan Log In.'), backgroundColor: Colors.green),
      );
      // Arahkan ke Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Navy background)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Bottom White Container
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      // Title
                      const Text(
                        'Create Your Account!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Choose account type
                      const Text(
                        'Choose account type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Account type toggle buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isJobSeeker = true),
                              child: _AccountTypeCard(
                                title: 'Job Seeker',
                                subtitle: "I'm looking for a job",
                                icon: Icons.person,
                                isSelected: _isJobSeeker,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isJobSeeker = false),
                              child: _AccountTypeCard(
                                title: 'Employer',
                                subtitle: 'I want to post jobs',
                                icon: Icons.work,
                                isSelected: !_isJobSeeker,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Username Field
                      CustomTextField(
                        label: 'Username',
                        hint: 'Username',
                        controller: _usernameCtrl,
                      ),
                      const SizedBox(height: 24),
                      
                      // Email Field (Dipisah dari phone)
                      CustomTextField(
                        label: 'Email',
                        hint: 'Email Address',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),

                      // Phone Field
                      CustomTextField(
                        label: 'Phone',
                        hint: 'Phone Number',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      
                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Password (Min. 6 Char)',
                        isPassword: true,
                        controller: _passwordCtrl,
                      ),
                      const SizedBox(height: 24),

                       // Confirm Password Field
                      CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm Password',
                        isPassword: true,
                        controller: _confirmCtrl,
                      ),
                      const SizedBox(height: 40),
                      
                      // Sign Up Button
                      SizedBox(
                        height: 58, 
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Log In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already Have An Account? ",
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginView()),
                              );
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: AppColors.primaryNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;

  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryNavy,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: isSelected ? Colors.white : AppColors.primaryNavy,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryNavy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isSelected ? Colors.white70 : AppColors.textGray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
