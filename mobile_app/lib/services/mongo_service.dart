import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoService {
  static late Db db;
  static late DbCollection users;



  // Ambil data lowongan kerja
  static Future<List<Map<String, dynamic>>> getJobVacancies() async {
    final collection = db.collection('job_vacancies');
    final jobs = await collection.find({'status': 'active'}).toList();
    return jobs.cast<Map<String, dynamic>>();
  }

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
