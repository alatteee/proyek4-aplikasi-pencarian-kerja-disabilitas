import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoService {
  static late Db db;
  static late DbCollection users;
  static late DbCollection userDetails; // Collection baru

  static Future<void> connect() async {
    final uri = dotenv.env['MONGODB_URI'];

    if (uri == null) {
      throw Exception("MONGODB_URI tidak ditemukan");
    }

    try {
      db = await Db.create(uri);
      await db.open();

      users = db.collection('users');
      userDetails = db.collection('user_details'); 

      print("✅ MongoDB Connected");
    } catch (e) {
      print("❌ MongoDB Connection Error: $e");
    }
  }
}
