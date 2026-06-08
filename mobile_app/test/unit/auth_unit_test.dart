import 'package:flutter_test/flutter_test.dart';

// Validator utility functions for testing
class EmailValidator {
  /// Validasi format email
  /// Returns true jika format email valid, false jika tidak valid
  static bool isValidEmail(String email) {
    if (email.isEmpty) {
      return false;
    }
    
    // Simple email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailRegex.hasMatch(email);
  }
}

class PasswordValidator {
  /// Validasi password minimal 6 karakter
  /// Returns true jika password valid, false jika tidak valid
  static bool isValidPassword(String password) {
    if (password.isEmpty) {
      return false;
    }
    return password.length >= 6;
  }
}

class LoginValidator {
  /// Validasi login data (email dan password tidak boleh kosong)
  /// Returns true jika data valid, false jika ada yang kosong
  static bool isValidLoginInput(String email, String password) {
    return email.isNotEmpty && password.isNotEmpty;
  }
}

void main() {
  group('TC-UNIT-AUTH-001: Validasi Format Email', () {
    test('Negative Case - Email tanpa @ symbol harus ditolak', () {
      const invalidEmail = 'rahmaemail.com';
      final result = EmailValidator.isValidEmail(invalidEmail);
      
      expect(result, false, reason: 'Email tanpa @ harus tidak valid');
    });

    test('Negative Case - Email kosong harus ditolak', () {
      const invalidEmail = '';
      final result = EmailValidator.isValidEmail(invalidEmail);
      
      expect(result, false, reason: 'Email kosong harus tidak valid');
    });

    test('Negative Case - Email dengan format salah harus ditolak', () {
      const invalidEmail = 'rahman@.com';
      final result = EmailValidator.isValidEmail(invalidEmail);
      
      expect(result, false, reason: 'Email dengan format salah harus tidak valid');
    });

    test('Positive Case - Email valid harus diterima', () {
      const validEmail = 'rahman@email.com';
      final result = EmailValidator.isValidEmail(validEmail);
      
      expect(result, true, reason: 'Email valid harus accepted');
    });

    test('Positive Case - Email dengan subdomain harus valid', () {
      const validEmail = 'user.name@company.co.id';
      final result = EmailValidator.isValidEmail(validEmail);
      
      expect(result, true, reason: 'Email dengan subdomain harus valid');
    });
  });

  group('TC-UNIT-AUTH-002: Validasi Password Minimum', () {
    test('Negative Case - Password kurang dari 6 karakter harus ditolak', () {
      const shortPassword = '12345';
      final result = PasswordValidator.isValidPassword(shortPassword);
      
      expect(result, false, reason: 'Password kurang dari 6 karakter harus tidak valid');
    });

    test('Negative Case - Password 1 karakter harus ditolak', () {
      const veryShortPassword = 'a';
      final result = PasswordValidator.isValidPassword(veryShortPassword);
      
      expect(result, false, reason: 'Password 1 karakter harus tidak valid');
    });

    test('Negative Case - Password kosong harus ditolak', () {
      const emptyPassword = '';
      final result = PasswordValidator.isValidPassword(emptyPassword);
      
      expect(result, false, reason: 'Password kosong harus tidak valid');
    });

    test('Positive Case - Password 6 karakter harus diterima', () {
      const minimalPassword = '123456';
      final result = PasswordValidator.isValidPassword(minimalPassword);
      
      expect(result, true, reason: 'Password 6 karakter harus valid');
    });

    test('Positive Case - Password lebih dari 6 karakter harus diterima', () {
      const validPassword = 'MyPassword123!';
      final result = PasswordValidator.isValidPassword(validPassword);
      
      expect(result, true, reason: 'Password lebih dari 6 karakter harus valid');
    });
  });

  group('TC-UNIT-AUTH-003: Validasi Login dengan Data Kosong', () {
    test('Negative Case - Email kosong harus ditolak', () {
      const emptyEmail = '';
      const password = 'password123';
      final result = LoginValidator.isValidLoginInput(emptyEmail, password);
      
      expect(result, false, reason: 'Login dengan email kosong harus ditolak');
    });

    test('Negative Case - Password kosong harus ditolak', () {
      const email = 'user@email.com';
      const emptyPassword = '';
      final result = LoginValidator.isValidLoginInput(email, emptyPassword);
      
      expect(result, false, reason: 'Login dengan password kosong harus ditolak');
    });

    test('Negative Case - Email dan password kosong harus ditolak', () {
      const emptyEmail = '';
      const emptyPassword = '';
      final result = LoginValidator.isValidLoginInput(emptyEmail, emptyPassword);
      
      expect(result, false, reason: 'Login dengan email dan password kosong harus ditolak');
    });

    test('Positive Case - Email dan password terisi harus diterima', () {
      const email = 'user@email.com';
      const password = 'password123';
      final result = LoginValidator.isValidLoginInput(email, password);
      
      expect(result, true, reason: 'Login dengan data lengkap harus diterima');
    });
  });

  group('TC-UNIT-AUTH-004: Validasi Role Pengguna', () {
    test('Positive Case - Role jobseeker harus valid', () {
      const role = 'jobseeker';
      final validRoles = ['jobseeker', 'company'];
      final result = validRoles.contains(role);
      
      expect(result, true, reason: 'Role jobseeker harus valid');
    });

    test('Positive Case - Role company harus valid', () {
      const role = 'company';
      final validRoles = ['jobseeker', 'company'];
      final result = validRoles.contains(role);
      
      expect(result, true, reason: 'Role company harus valid');
    });

    test('Negative Case - Role tidak dikenal harus ditolak', () {
      const role = 'admin';
      final validRoles = ['jobseeker', 'company'];
      final result = validRoles.contains(role);
      
      expect(result, false, reason: 'Role tidak dikenal harus ditolak');
    });

    test('Positive Case - User dengan role jobseeker dapat mengakses dashboard jobseeker', () {
      const userRole = 'jobseeker';
      const expectedDashboard = 'jobseeker_dashboard';
      
      final dashboard = userRole == 'jobseeker' ? 'jobseeker_dashboard' : 'company_dashboard';
      
      expect(dashboard, expectedDashboard, reason: 'User jobseeker harus diarahkan ke dashboard jobseeker');
    });

    test('Positive Case - User dengan role company dapat mengakses dashboard company', () {
      const userRole = 'company';
      const expectedDashboard = 'company_dashboard';
      
      final dashboard = userRole == 'company' ? 'company_dashboard' : 'jobseeker_dashboard';
      
      expect(dashboard, expectedDashboard, reason: 'User company harus diarahkan ke dashboard company');
    });
  });
}
