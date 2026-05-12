import 'package:flutter/material.dart' hide State;
import 'connectivity_service.dart';
import 'offline_service.dart';
import 'mongo_service.dart';
import '../features/profile/profile_controller.dart';
import '../features/cv/cv_controller.dart';

class SyncService {
  static bool _isSyncing = false;
  static bool? _lastConnectionStatus;

  static void initialize(BuildContext context) {
    connectivityService.connectionStream.listen((hasConnection) {
      if (_lastConnectionStatus == hasConnection) return;
      _lastConnectionStatus = hasConnection;

      if (hasConnection) {
        _handleBackOnline(context);
      } else {
        _handleOffline(context);
      }
    });
  }

  static void _handleOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Koneksi terputus. Data akan tersimpan offline.'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
  }

  static void _handleBackOnline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Koneksi internet tersedia. Mensinkronisasi...'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    performSync();
  }

  static Future<void> performSync() async {
    if (_isSyncing) return;

    final queue = OfflineService.getSyncQueue();

    if (queue.isEmpty) {
      print('DEBUG: Sync queue is empty');
      return;
    }

    _isSyncing = true;
    print('DEBUG: Starting Background Sync for ${queue.length} item(s)...');

    final failedItems = <Map<String, dynamic>>[];

    try {
      print('⏳ Waiting for MongoService to be ready...');
      await MongoService.ensureConnected();

      print('🔍 Verifying MongoService connection is LIVE...');

      int verifyRetries = 0;
      bool isLive = false;

      while (!isLive && verifyRetries < 10) {
        isLive = await MongoService.verifyConnected();

        if (!isLive && verifyRetries < 9) {
          print(
            '⏳ Verify attempt ${verifyRetries + 1}/10 failed. Retrying...',
          );
          await Future.delayed(const Duration(milliseconds: 500));
        }

        verifyRetries++;
      }

      if (!isLive) {
        print(
          '❌ FATAL: MongoService connection cannot be verified. Sync cancelled.',
        );
        return;
      }

      print('✅ MongoService VERIFIED LIVE. Processing ${queue.length} item(s)...');

      for (final item in queue) {
        final action = item['action']?.toString() ?? '';
        final rawData = item['data'];

        if (action.isEmpty || rawData == null) {
          print('⚠️ Invalid sync item skipped: $item');
          continue;
        }

        final data = Map<String, dynamic>.from(rawData);

        try {
          print('📤 Syncing: $action');

          final success = await _syncSingleItem(
            action: action,
            data: data,
          );

          if (success) {
            print('✅ Sync successful: $action');
          } else {
            print('❌ Sync returned false: $action');
            failedItems.add(item);
          }
        } catch (itemError) {
          print('❌ ERROR: Sync item failed ($action): $itemError');
          failedItems.add(item);
        }
      }

      await OfflineService.clearSyncQueue();

      for (final failedItem in failedItems) {
        await OfflineService.addToSyncQueue(
          failedItem['action']?.toString() ?? '',
          Map<String, dynamic>.from(failedItem['data']),
        );
      }

      if (failedItems.isEmpty) {
        print('✅ All sync completed successfully');
      } else {
        print(
          '⚠️ Sync completed with ${failedItems.length} failed item(s). Failed item(s) kept in queue.',
        );
      }
    } catch (e) {
      print('❌ ERROR: Sync process failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  static Future<bool> _syncSingleItem({
    required String action,
    required Map<String, dynamic> data,
  }) async {
    if (action == 'apply_job') {
      return await MongoService.submitJobApplication(
        applicationData: data,
      );
    }

    if (action == 'update_profile') {
      return await ProfileController.createOrUpdateProfile(data);
    }

    if (action == 'create_cv') {
      return await CvController.createCv(data);
    }

    if (action == 'update_cv') {
      final userId = data['userId'];
      final cvData = Map<String, dynamic>.from(data['data']);

      return await CvController.updateCv(userId, cvData);
    }

    if (action == 'update_company_profile') {
      final companyId = data['companyId']?.toString() ?? '';
      final compData = Map<String, dynamic>.from(data['data']);

      return await MongoService.updateCompanyProfile(
        companyId: companyId,
        data: compData,
      );
    }

    print('⚠️ Unknown sync action: $action');
    return false;
  }
}