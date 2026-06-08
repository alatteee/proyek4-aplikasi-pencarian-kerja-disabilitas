import 'package:flutter_test/flutter_test.dart';

// Status Mapper utility untuk testing
class ApplicationStatusMapper {
  /// Mapping status lamaran ke status filter
  /// Status asli: dikirim, ditinjau, wawancara, diterima, ditolak
  static String mapStatusToFilter(String? status) {
    final s = (status ?? '').toLowerCase().trim();

    // Status awal / baru dikirim
    if (s == 'dikirim' || s == 'submitted' || s == 'pending' || s == 'menunggu') {
      return 'Dikirim';
    }

    // Status proses berjalan
    if (s == 'ditinjau' || s == 'reviewed' || s == 'review' || s == 'diproses' || s == 'processed' || s == 'wawancara' || s == 'interview') {
      return 'Diproses';
    }

    // Status akhir berhasil
    if (s == 'diterima' || s == 'accepted' || s == 'lolos' || s == 'selesai') {
      return 'Selesai';
    }

    // Status akhir ditolak
    if (s == 'ditolak' || s == 'rejected') {
      return 'Ditolak';
    }

    // Default return jika status tidak dikenal
    return 'Dikirim';
  }

  /// Mapping status lamaran ke label yang ditampilkan
  static String mapStatusToLabel(String? status) {
    final s = (status ?? '').toLowerCase().trim();

    if (s == 'ditinjau' || s == 'reviewed' || s == 'review') {
      return 'Ditinjau';
    }

    if (s == 'wawancara' || s == 'interview') {
      return 'Wawancara';
    }

    if (s == 'diproses' || s == 'processed') {
      return 'Diproses';
    }

    if (s == 'diterima' || s == 'accepted' || s == 'lolos') {
      return 'Diterima';
    }

    if (s == 'selesai') {
      return 'Selesai';
    }

    if (s == 'ditolak' || s == 'rejected') {
      return 'Ditolak';
    }

    return 'Dikirim';
  }

  /// Cek apakah status adalah status akhir (terminal state)
  static bool isTerminalStatus(String? status) {
    final filter = mapStatusToFilter(status);
    return filter == 'Selesai' || filter == 'Ditolak';
  }

  /// Get valid status list
  static List<String> getValidStatuses() {
    return ['Dikirim', 'Diproses', 'Selesai', 'Ditolak'];
  }
}

void main() {
  group('TC-UNIT-APP-001: Mapping Status Lamaran', () {
    test('Positive Case - Status "dikirim" harus dimapping ke "Dikirim"', () {
      const status = 'dikirim';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Dikirim',
          reason: 'Status "dikirim" harus ditampilkan sebagai "Dikirim"');
    });

    test('Positive Case - Status "ditinjau" harus dimapping ke "Ditinjau"', () {
      const status = 'ditinjau';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Ditinjau',
          reason: 'Status "ditinjau" harus ditampilkan sebagai "Ditinjau"');
    });

    test('Positive Case - Status "wawancara" harus dimapping ke "Wawancara"', () {
      const status = 'wawancara';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Wawancara',
          reason: 'Status "wawancara" harus ditampilkan sebagai "Wawancara"');
    });

    test('Positive Case - Status "diterima" harus dimapping ke "Diterima"', () {
      const status = 'diterima';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Diterima',
          reason: 'Status "diterima" harus ditampilkan sebagai "Diterima"');
    });

    test('Positive Case - Status "ditolak" harus dimapping ke "Ditolak"', () {
      const status = 'ditolak';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Ditolak',
          reason: 'Status "ditolak" harus ditampilkan sebagai "Ditolak"');
    });

    test('Positive Case - Status case-insensitive (uppercase) harus dimapping', () {
      const status = 'DITERIMA';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Diterima',
          reason:
              'Status case-insensitive harus tetap dimapping dengan benar');
    });

    test('Positive Case - Status dengan whitespace harus dimapping', () {
      const status = '  ditinjau  ';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Ditinjau',
          reason: 'Status dengan whitespace harus tetap dimapping dengan benar');
    });

    test(
        'Positive Case - Status dari database (submitted) harus dimapping ke Dikirim',
        () {
          const status = 'submitted';
          final result = ApplicationStatusMapper.mapStatusToFilter(status);

          expect(result, 'Dikirim',
              reason: 'Status submitted dari DB harus dimapping ke Dikirim');
        });

    test(
        'Positive Case - Status dari database (interview) harus dimapping ke Diproses',
        () {
          const status = 'interview';
          final result = ApplicationStatusMapper.mapStatusToFilter(status);

          expect(result, 'Diproses',
              reason: 'Status interview dari DB harus dimapping ke Diproses');
        });

    test(
        'Positive Case - Status dari database (accepted) harus dimapping ke Selesai',
        () {
          const status = 'accepted';
          final result = ApplicationStatusMapper.mapStatusToFilter(status);

          expect(result, 'Selesai',
              reason: 'Status accepted dari DB harus dimapping ke Selesai');
        });
  });

  group('TC-UNIT-APP-002: Validasi Status Lamaran Tidak Dikenal', () {
    test('Edge Case - Status kosong harus dianggap valid dan ditampilkan default',
        () {
      const status = '';
      final result = ApplicationStatusMapper.mapStatusToLabel(status);

      expect(result, 'Dikirim',
          reason:
              'Status kosong harus ditampilkan default (Dikirim) tanpa crash');
    });

    test('Edge Case - Status null harus dianggap valid dan ditampilkan default',
        () {
      final result = ApplicationStatusMapper.mapStatusToLabel(null);

      expect(result, 'Dikirim',
          reason:
              'Status null harus ditampilkan default (Dikirim) tanpa crash');
    });

    test(
        'Edge Case - Status tidak dikenal harus ditampilkan default tanpa crash',
        () {
          const status = 'unknown_status_xyz';
          final result = ApplicationStatusMapper.mapStatusToLabel(status);

          expect(result, 'Dikirim',
              reason:
                  'Status tidak dikenal harus ditampilkan default (Dikirim) tanpa crash');
        });

    test('Edge Case - Status tidak dikenal di filter harus return default', () {
      const status = 'status_tidak_ada';
      final result = ApplicationStatusMapper.mapStatusToFilter(status);

      expect(result, 'Dikirim',
          reason:
              'Status tidak dikenal di filter harus return default (Dikirim)');
    });

    test('Edge Case - Sistem tetap berjalan dengan status aneh', () {
      const statusList = ['', 'xyz', 'unknown', '123'];

      for (final status in statusList) {
        final result = ApplicationStatusMapper.mapStatusToLabel(status);
        // Harus selalu return valid status tanpa throw exception
        expect(result, isNotEmpty, reason: 'Harus always return non-empty string');
        expect(ApplicationStatusMapper.getValidStatuses().contains(result) ||
            result == 'Dikirim' ||
            result == 'Ditinjau' ||
            result == 'Wawancara' ||
            result == 'Diproses' ||
            result == 'Diterima' ||
            result == 'Selesai' ||
            result == 'Ditolak', true);
      }
    });

    test('Edge Case - Tidak terjadi exception saat process status aneh', () {
      expect(
        () {
          ApplicationStatusMapper.mapStatusToLabel('!!!invalid!!!');
          ApplicationStatusMapper.mapStatusToFilter(null);
          ApplicationStatusMapper.mapStatusToLabel('');
        },
        returnsNormally,
        reason: 'Tidak boleh throw exception untuk input apapun',
      );
    });
  });
}
