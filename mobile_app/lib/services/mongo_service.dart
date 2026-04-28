import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoService {
  static late Db db;
  static late DbCollection users;

  static Future<void> connect() async {
    final uri = dotenv.env['MONGODB_URI'];

    if (uri == null) {
      throw Exception("MONGODB_URI tidak ditemukan");
    }

    db = await Db.create(uri);
    await db.open();

    users = db.collection('users');

    print("✅ MongoDB Connected");
  }
}
