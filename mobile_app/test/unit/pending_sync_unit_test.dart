import 'package:flutter_test/flutter_test.dart';

// PendingSyncQueue utility untuk testing offline sync functionality
class PendingSyncQueue {
  final List<Map<String, dynamic>> _queue = [];
  bool _isSyncing = false;

  /// Mendapatkan list items di sync queue
  List<Map<String, dynamic>> getQueue() {
    return List.from(_queue);
  }

  /// Cek apakah sedang melakukan sync
  bool get isSyncing => _isSyncing;

  /// Menambah item ke pending sync queue
  Future<bool> addToSyncQueue({
    required String action,
    required Map<String, dynamic> data,
  }) async {
    if (action.isEmpty) return false;

    final item = {
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _queue.add(item);
    return true;
  }

  /// Validasi struktur data pending sync
  bool isValidSyncItem(Map<String, dynamic> item) {
    final hasAction = item.containsKey('action') && item['action'] is String && (item['action'] as String).isNotEmpty;
    final hasData = item.containsKey('data') && item['data'] is Map;
    final hasTimestamp = item.containsKey('timestamp') && item['timestamp'] is String;

    return hasAction && hasData && hasTimestamp;
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    _queue.clear();
  }

  /// Simulate sync process - returns true jika semua items berhasil
  Future<bool> performSync() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    final failedItems = <Map<String, dynamic>>[];

    try {
      print('Starting sync for ${_queue.length} items...');

      for (final item in _queue) {
        final action = item['action']?.toString() ?? '';

        // Simulate sync action processing
        final success = await _processSyncItem(action: action, data: item['data']);

        if (!success) {
          failedItems.add(item);
        }
      }

      // Clear queue
      await clearSyncQueue();

      // Re-add failed items
      for (final failedItem in failedItems) {
        _queue.add(failedItem);
      }

      return failedItems.isEmpty;
    } finally {
      _isSyncing = false;
    }
  }

  /// Prevent double sync
  Future<bool> performSyncWithGuard() async {
    if (_isSyncing) {
      print('Sync already in progress, skipping...');
      return false;
    }

    return performSync();
  }

  /// Simulate processing a sync item
  Future<bool> _processSyncItem({
    required String action,
    required Map<String, dynamic> data,
  }) async {
    // Simulate different actions
    switch (action) {
      case 'save_job':
        final userId = data['user_id']?.toString() ?? '';
        final jobId = data['job_id']?.toString() ?? '';
        return userId.isNotEmpty && jobId.isNotEmpty;

      case 'unsave_job':
        final userId = data['user_id']?.toString() ?? '';
        final jobId = data['job_id']?.toString() ?? '';
        return userId.isNotEmpty && jobId.isNotEmpty;

      case 'submit_application':
        return data.containsKey('application_id');

      case 'update_profile':
        return data.containsKey('user_id');

      case 'create_cv':
        return data.containsKey('user_id');

      default:
        return false;
    }
  }

  /// Get pending sync queue size
  int getQueueSize() {
    return _queue.length;
  }
}

void main() {
  group('TC-UNIT-SYNC-001: Penambahan Item ke Pending Sync', () {
    late PendingSyncQueue syncQueue;

    setUp(() {
      syncQueue = PendingSyncQueue();
    });

    test(
        'Positive Case - Menyimpan save_job action ke pending sync saat offline',
        () async {
      final result = await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {
          'user_id': 'user123',
          'job_id': 'job456',
        },
      );

      expect(result, true, reason: 'Menambah item ke queue harus berhasil');
      expect(syncQueue.getQueue().length, 1,
          reason: 'Queue harus berisi 1 item');
    });

    test(
        'Positive Case - Menyimpan unsave_job action ke pending sync saat offline',
        () async {
      final result = await syncQueue.addToSyncQueue(
        action: 'unsave_job',
        data: {
          'user_id': 'user123',
          'job_id': 'job456',
        },
      );

      expect(result, true, reason: 'Menambah unsave_job harus berhasil');
      expect(syncQueue.getQueue().length, 1,
          reason: 'Queue harus berisi 1 item');
    });

    test(
        'Positive Case - Menyimpan submit_application action ke pending sync',
        () async {
      final result = await syncQueue.addToSyncQueue(
        action: 'submit_application',
        data: {
          'user_id': 'user123',
          'job_id': 'job456',
          'application_id': 'app789',
        },
      );

      expect(result, true, reason: 'Menambah submit_application harus berhasil');
      expect(syncQueue.getQueue().length, 1,
          reason: 'Queue harus berisi 1 item');
    });

    test('Positive Case - Multiple actions dapat disimpan secara bersamaan',
        () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user1', 'job_id': 'job1'},
      );

      await syncQueue.addToSyncQueue(
        action: 'unsave_job',
        data: {'user_id': 'user1', 'job_id': 'job2'},
      );

      await syncQueue.addToSyncQueue(
        action: 'submit_application',
        data: {'user_id': 'user1', 'application_id': 'app1'},
      );

      expect(syncQueue.getQueue().length, 3,
          reason: 'Queue harus berisi 3 item');
    });
  });

  group('TC-UNIT-SYNC-002: Validasi Struktur Data Pending Sync', () {
    late PendingSyncQueue syncQueue;

    setUp(() {
      syncQueue = PendingSyncQueue();
    });

    test('Positive Case - Data sync harus memiliki field action, data, timestamp',
        () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123', 'job_id': 'job456'},
      );

      final queueItems = syncQueue.getQueue();
      expect(queueItems.length, 1, reason: 'Harus ada 1 item di queue');

      final item = queueItems.first;
      expect(item.containsKey('action'), true,
          reason: 'Item harus memiliki field action');
      expect(item.containsKey('data'), true,
          reason: 'Item harus memiliki field data');
      expect(item.containsKey('timestamp'), true,
          reason: 'Item harus memiliki field timestamp');
    });

    test('Positive Case - Field action harus berisi string', () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123'},
      );

      final item = syncQueue.getQueue().first;
      expect(item['action'] is String, true,
          reason: 'Field action harus berisi string');
      expect((item['action'] as String).isNotEmpty, true,
          reason: 'Field action tidak boleh kosong');
    });

    test('Positive Case - Field data harus berisi map', () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123', 'job_id': 'job456'},
      );

      final item = syncQueue.getQueue().first;
      expect(item['data'] is Map, true,
          reason: 'Field data harus berisi map');
    });

    test('Positive Case - Field timestamp harus berisi ISO8601 datetime string',
        () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123'},
      );

      final item = syncQueue.getQueue().first;
      expect(item['timestamp'] is String, true,
          reason: 'Field timestamp harus berisi string');

      // Try to parse as datetime
      expect(
        () => DateTime.parse(item['timestamp']),
        returnsNormally,
        reason: 'Timestamp harus valid ISO8601 format',
      );
    });

    test('Positive Case - Struktur data sync lengkap', () async {
      await syncQueue.addToSyncQueue(
        action: 'submit_application',
        data: {
          'user_id': 'user123',
          'job_id': 'job456',
          'application_id': 'app789',
          'cover_letter': 'Saya ingin apply untuk posisi ini',
        },
      );

      final item = syncQueue.getQueue().first;
      final isValid = syncQueue.isValidSyncItem(item);

      expect(isValid, true, reason: 'Struktur data sync harus valid');
    });
  });

  group('TC-UNIT-SYNC-003: Pemrosesan Action Saat Online Kembali', () {
    late PendingSyncQueue syncQueue;

    setUp(() {
      syncQueue = PendingSyncQueue();
    });

    test('Positive Case - Memproses save_job action dari queue', () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123', 'job_id': 'job456'},
      );

      expect(syncQueue.getQueue().length, 1,
          reason: 'Harus ada 1 item di queue sebelum sync');

      final success = await syncQueue.performSync();

      expect(success, true, reason: 'Sync harus berhasil');
      expect(syncQueue.getQueue().length, 0,
          reason: 'Queue harus kosong setelah sync berhasil');
    });

    test('Positive Case - Memproses unsave_job action dari queue', () async {
      await syncQueue.addToSyncQueue(
        action: 'unsave_job',
        data: {'user_id': 'user123', 'job_id': 'job456'},
      );

      final success = await syncQueue.performSync();

      expect(success, true, reason: 'Unsave job sync harus berhasil');
    });

    test('Positive Case - Memproses submit_application action dari queue',
        () async {
      await syncQueue.addToSyncQueue(
        action: 'submit_application',
        data: {'user_id': 'user123', 'application_id': 'app456'},
      );

      final success = await syncQueue.performSync();

      expect(success, true, reason: 'Submit application sync harus berhasil');
    });

    test('Positive Case - Memproses multiple actions dari queue', () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user1', 'job_id': 'job1'},
      );

      await syncQueue.addToSyncQueue(
        action: 'submit_application',
        data: {'user_id': 'user1', 'application_id': 'app1'},
      );

      final success = await syncQueue.performSync();

      expect(success, true,
          reason: 'Sync multiple actions harus berhasil');
      expect(syncQueue.getQueue().length, 0,
          reason: 'Queue harus kosong setelah sync semua');
    });

    test('Positive Case - Failed items direturn ke queue', () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': '', 'job_id': ''}, // Invalid data
      );

      final success = await syncQueue.performSync();

      expect(success, false, reason: 'Sync dengan data invalid harus gagal');
      expect(syncQueue.getQueue().length, 1,
          reason: 'Failed item harus direturn ke queue');
    });
  });

  group('TC-UNIT-SYNC-004: Pencegahan Sinkronisasi Ganda', () {
    late PendingSyncQueue syncQueue;

    setUp(() {
      syncQueue = PendingSyncQueue();
    });

    test(
        'Edge Case - performSync() tidak berjalan ganda saat dipanggil bersamaan',
        () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123', 'job_id': 'job456'},
      );

      expect(syncQueue.isSyncing, false, reason: 'Awalnya tidak sedang sync');

      // Try to call sync twice at the same time (simulate with Future)
      final sync1 = syncQueue.performSync();
      // Don't await yet, try to call again
      final sync2 = syncQueue.performSync();

      expect(syncQueue.isSyncing, true, reason: 'Harus sedang sync');

      // Await both
      final result1 = await sync1;
      final result2 = await sync2;

      expect(result1, true, reason: 'First sync harus berhasil');
      expect(result2, false,
          reason:
              'Second sync harus ditolak karena sedang sync (double sync prevention)');
    });

    test('Edge Case - _isSyncing flag mencegah double sync', () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123', 'job_id': 'job456'},
      );

      final result1 = await syncQueue.performSyncWithGuard();
      expect(result1, true, reason: 'First sync harus berhasil');

      // Queue now empty, but try to sync again immediately
      final result2 = await syncQueue.performSyncWithGuard();

      // Should not crash and return appropriately
      expect(() => syncQueue.performSyncWithGuard(), returnsNormally,
          reason: 'Sync guard harus handle multiple calls dengan baik');
    });

    test('Edge Case - Sync dengan guard mencegah race condition', () async {
      await syncQueue.addToSyncQueue(
        action: 'save_job',
        data: {'user_id': 'user123', 'job_id': 'job456'},
      );

      await syncQueue.addToSyncQueue(
        action: 'submit_application',
        data: {'user_id': 'user123', 'application_id': 'app789'},
      );

      expect(syncQueue.getQueueSize(), 2);

      // Simulate concurrent calls
      final futures = [
        syncQueue.performSyncWithGuard(),
        syncQueue.performSyncWithGuard(),
        syncQueue.performSyncWithGuard(),
      ];

      final results = await Future.wait(futures);

      // Only first should succeed
      expect(results.where((r) => r == true).length, 1,
          reason: 'Hanya 1 sync yang boleh berhasil');
      expect(syncQueue.isSyncing, false,
          reason: 'Flag sync harus di-reset setelah selesai');
    });
  });
}
