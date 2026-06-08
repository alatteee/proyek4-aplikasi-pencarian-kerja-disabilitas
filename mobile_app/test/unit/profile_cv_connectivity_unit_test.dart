import 'package:flutter_test/flutter_test.dart';

class CVValidator {
  static bool isValidCV(Map<String, dynamic> cvData) {
    return cvData.containsKey('education') &&
        cvData.containsKey('experience') &&
        cvData.containsKey('skills') &&
        cvData['education'] != null &&
        cvData['experience'] != null &&
        cvData['skills'] != null &&
        cvData['education'].toString().isNotEmpty &&
        cvData['experience'].toString().isNotEmpty &&
        cvData['skills'] is List &&
        (cvData['skills'] as List).isNotEmpty;
  }
}

class ProfileValidator {
  static Map<String, String> validateProfileUpdate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    if (data.containsKey('name') && data['name'].toString().trim().isEmpty) {
      errors['name'] = 'Nama tidak boleh kosong';
    }

    if (data.containsKey('phone') && data['phone'].toString().length < 10) {
      errors['phone'] = 'Nomor telepon minimal 10 digit';
    }

    if (data.containsKey('skills') &&
        (data['skills'] is List) &&
        (data['skills'] as List).isEmpty) {
      errors['skills'] = 'Skills tidak boleh kosong';
    }

    return errors;
  }
}

class ConnectivityChecker {
  bool _isOnline;

  ConnectivityChecker(this._isOnline);

  bool get isOnline => _isOnline;

  Future<bool> checkConnection() async {
    return _isOnline;
  }

  void goOffline() {
    _isOnline = false;
  }

  void goOnline() {
    _isOnline = true;
  }

  void setConnectionStatus(bool online) {
    _isOnline = online;
  }
}

void main() {
  group('TC-UNIT-CV-001: Validasi Data CV Digital', () {
    test('CV tanpa field education ditolak', () {
      final cvData = {
        'experience': 'Magang Flutter Developer',
        'skills': ['Flutter', 'Dart'],
      };

      expect(CVValidator.isValidCV(cvData), false);
    });

    test('CV lengkap diterima', () {
      final cvData = {
        'education': 'D3 Teknik Informatika',
        'experience': 'Magang Flutter Developer',
        'skills': ['Flutter', 'Dart'],
      };

      expect(CVValidator.isValidCV(cvData), true);
    });
  });

  group('TC-UNIT-PROFILE-001: Validasi Update Profil Pengguna', () {
    test('Update profil dengan nama baru berhasil', () {
      final data = {
        'name': 'Rahma Attaya',
      };

      final errors = ProfileValidator.validateProfileUpdate(data);

      expect(errors.isEmpty, true);
    });

    test('Update dengan nama kosong error', () {
      final data = {
        'name': '',
      };

      final errors = ProfileValidator.validateProfileUpdate(data);

      expect(errors.containsKey('name'), true);
    });

    test('Update dengan nomor telepon invalid error', () {
      final data = {
        'phone': '08123',
      };

      final errors = ProfileValidator.validateProfileUpdate(data);

      expect(errors.containsKey('phone'), true);
    });
  });

  group('TC-UNIT-CONN-001: Pengecekan Status Koneksi', () {
    test('Mengembalikan status online', () async {
      final checker = ConnectivityChecker(true);

      final result = await checker.checkConnection();

      expect(result, true);
    });

    test('Mengembalikan status offline', () async {
      final checker = ConnectivityChecker(false);

      final result = await checker.checkConnection();

      expect(result, false);
    });

    test('Simulate going offline', () {
      final checker = ConnectivityChecker(true);

      checker.goOffline();

      expect(checker.isOnline, false);
    });

    test('Simulate going online', () {
      final checker = ConnectivityChecker(false);

      checker.goOnline();

      expect(checker.isOnline, true);
    });
  });
}