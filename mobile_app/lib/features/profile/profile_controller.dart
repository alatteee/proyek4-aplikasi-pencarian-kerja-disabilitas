import 'package:mongo_dart/mongo_dart.dart';
import '../../services/mongo_service.dart';

class ProfileController {
  
  static Future<Map<String, dynamic>?> getProfileByUserId(ObjectId userId) async {
    if (MongoService.db.state == State.closed) {
      await MongoService.connect();
    }
    try {
      final profile = await MongoService.userDetails.findOne(where.eq('user_id', userId));
      return profile;
    } catch (e) {
      print('Error getProfileByUserId: $e');
      return null;
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

  static Future<bool> createOrUpdateProfile(Map<String, dynamic> data) async {
    try {
      final userId = data['user_id'];
      
      if (await profileExists(userId)) {
        data['updated_at'] = DateTime.now();
        await MongoService.userDetails.update(where.eq('user_id', userId), { r'$set': data });
      } else {
        data['created_at'] = DateTime.now();
        data['updated_at'] = DateTime.now();
        await MongoService.userDetails.insert(data);
      }
      return true;
    } catch (e) {
      print('Error createOrUpdateProfile: $e');
      return false;
    }
  }
}

