import 'package:mongo_dart/mongo_dart.dart';
import '../../services/mongo_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/offline_service.dart';
import '../auth/auth_controller.dart';

class ProfileController {
  
  static Future<Map<String, dynamic>?> getProfileByUserId(ObjectId userId) async {
    try {
      final hasConnection = await connectivityService.checkConnection();
      if (!hasConnection) {
        print('📱 Profile: Offline. Using cache.');
        return OfflineService.getCachedUserProfile(userId.toHexString());
      }

      // Cek dengan truly verify connection
      await MongoService.ensureConnected();
      final isLive = await MongoService.verifyConnected();
      
      if (!isLive) {
        print('⚠️ Profile: DB not live. Using cache.');
        return OfflineService.getCachedUserProfile(userId.toHexString());
      }

      final profile = await MongoService.userDetails.findOne(where.eq('user_id', userId));
      
      if (profile != null) {
        // Update cache dengan data terbaru
        await OfflineService.cacheUserProfile(userId.toHexString(), profile);
      } else {
        // Kalau DB tidak ada tapi cache ada, gunakan cache
        final cachedProfile = OfflineService.getCachedUserProfile(userId.toHexString());
        if (cachedProfile != null) {
          print('💾 Profile: Using cached profile (DB has none)');
          return cachedProfile;
        }
      }
      
      return profile;
    } catch (e) {
      print('❌ Error getProfileByUserId: $e');
      // Fallback ke cache saat error
      return OfflineService.getCachedUserProfile(userId.toHexString());
    }
  }

  static Future<bool> profileExists(ObjectId userId) async {
    try {
      final profile = await getProfileByUserId(userId);
      return profile != null;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updatePassword(ObjectId userId, String oldPassword, String newPassword) async {
    try {
      // Password update biasanya membutuhkan koneksi real-time
      final hasConnection = await connectivityService.checkConnection();
      if (!hasConnection) return false;

      await MongoService.ensureConnected();
      // 1. Hash input password lama & baru menggunakan method dari AuthController
      final oldPasswordHash = AuthController.hashPassword(oldPassword.trim());
      final newPasswordHash = AuthController.hashPassword(newPassword.trim());

      // 2. Cari user dengan ID dan SHA-256 hash password lama yang sesuai
      final user = await MongoService.users.findOne(
        where.id(userId).eq('password_hash', oldPasswordHash)
      );
      
      if (user == null) {
        print('Verifikasi Gagal: Password lama (setelah dihash) tidak cocok dengan password_hash di DB');
        return false;
      }

      // 3. Update field password_hash dengan hash baru
      await MongoService.users.update(
        where.id(userId),
        modify.set('password_hash', newPasswordHash).set('updated_at', DateTime.now())
      );
      
      print('Update Password Berhasil');
      return true;
    } catch (e) {
      print('Error detail updatePassword: $e');
      return false;
    }
  }

  static Future<bool> createOrUpdateProfile(Map<String, dynamic> data) async {
    try {
      final userId = data['user_id'] as ObjectId;
      final hasConnection = await connectivityService.checkConnection();
      
      if (!hasConnection) {
        print('📱 Profile update: Offline. Queueing sync.');
        // Update local cache agar UI langsung berubah
        await OfflineService.cacheUserProfile(userId.toHexString(), data);
        await OfflineService.addToSyncQueue('update_profile', data);
        return true;
      }

      await MongoService.ensureConnected();
      
      // Verify koneksi sebelum operasi DB
      final isLive = await MongoService.verifyConnected();
      if (!isLive) {
        print('⚠️ Profile update: DB not live. Queueing sync.');
        await OfflineService.cacheUserProfile(userId.toHexString(), data);
        await OfflineService.addToSyncQueue('update_profile', data);
        return true;
      }
      
      if (await profileExists(userId)) {
        data['updated_at'] = DateTime.now();
        await MongoService.userDetails.update(where.eq('user_id', userId), { r'$set': data });
      } else {
        data['created_at'] = DateTime.now();
        data['updated_at'] = DateTime.now();
        await MongoService.userDetails.insert(data);
      }

      // Update local cache setelah sukses online
      await OfflineService.cacheUserProfile(userId.toHexString(), data);
      
      return true;
    } catch (e) {
      print('❌ Error createOrUpdateProfile: $e');
      // Fallback: cache dan queue untuk sync nanti
      try {
        final userId = data['user_id'] as ObjectId;
        await OfflineService.cacheUserProfile(userId.toHexString(), data);
        await OfflineService.addToSyncQueue('update_profile', data);
        return true;
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        return false;
      }
    }
  }
}

