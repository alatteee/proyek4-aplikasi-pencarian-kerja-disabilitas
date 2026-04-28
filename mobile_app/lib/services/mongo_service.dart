import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static late Db db;
  static late DbCollection users;

  static Future<void> connect() async {
    final uri = dotenv.env['MONGODB_URI'];

    if (uri == null || uri.isEmpty) {
      throw Exception('MONGODB_URI tidak ditemukan');
    }

    db = await Db.create(uri);
    await db.open();

    users = db.collection('users');

    // ignore: avoid_print
    print('✅ MongoDB Connected');
  }

  static DbCollection get _jobVacanciesCollection => db.collection('job_vacancies');
  static DbCollection get _savedJobsCollection => db.collection('saved_jobs');

  static String getMongoId(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static Future<List<Map<String, dynamic>>> getJobVacancies() async {
    try {
      final jobs = await _jobVacanciesCollection
          .find(where.eq('status', 'active').sortBy('created_at', descending: true))
          .toList();

      return jobs.cast<Map<String, dynamic>>();
    } catch (e) {
      // ignore: avoid_print
      print('Gagal mengambil data lowongan: $e');
      return [];
    }
  }

  static Future<bool> saveJob({
    required String userId,
    required String jobId,
  }) async {
    try {
      if (userId.isEmpty || jobId.isEmpty) return false;

      final existing = await _savedJobsCollection.findOne({
        'user_id': userId,
        'job_id': jobId,
      });

      if (existing != null) return true;

      await _savedJobsCollection.insertOne({
        'user_id': userId,
        'job_id': jobId,
        'saved_at': DateTime.now().toUtc(),
      });

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Gagal menyimpan lowongan: $e');
      return false;
    }
  }

  static Future<bool> unsaveJob({
    required String userId,
    required String jobId,
  }) async {
    try {
      if (userId.isEmpty || jobId.isEmpty) return false;

      await _savedJobsCollection.deleteOne({
        'user_id': userId,
        'job_id': jobId,
      });

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Gagal menghapus lowongan tersimpan: $e');
      return false;
    }
  }

  static Future<bool> isJobSaved({
    required String userId,
    required String jobId,
  }) async {
    try {
      if (userId.isEmpty || jobId.isEmpty) return false;

      final savedJob = await _savedJobsCollection.findOne({
        'user_id': userId,
        'job_id': jobId,
      });

      return savedJob != null;
    } catch (e) {
      // ignore: avoid_print
      print('Gagal mengecek lowongan tersimpan: $e');
      return false;
    }
  }

  static Future<Set<String>> getSavedJobIds({required String userId}) async {
    try {
      if (userId.isEmpty) return <String>{};

      final savedJobs = await _savedJobsCollection
          .find(where.eq('user_id', userId))
          .toList();

      return savedJobs
          .map((item) => item['job_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e) {
      // ignore: avoid_print
      print('Gagal mengambil id lowongan tersimpan: $e');
      return <String>{};
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedJobs({required String userId}) async {
    try {
      if (userId.isEmpty) return [];

      final savedJobs = await _savedJobsCollection
          .find(where.eq('user_id', userId).sortBy('saved_at', descending: true))
          .toList();

      if (savedJobs.isEmpty) return [];

      final savedAtByJobId = <String, dynamic>{};
      final savedJobIds = <String>[];

      for (final savedJob in savedJobs) {
        final jobId = savedJob['job_id']?.toString() ?? '';
        if (jobId.isNotEmpty) {
          savedJobIds.add(jobId);
          savedAtByJobId[jobId] = savedJob['saved_at'];
        }
      }

      if (savedJobIds.isEmpty) return [];

      final activeJobs = await _jobVacanciesCollection
          .find(where.eq('status', 'active'))
          .toList();

      final result = activeJobs
          .where((job) => savedJobIds.contains(getMongoId(job['_id'])))
          .map<Map<String, dynamic>>((job) {
            final jobMap = Map<String, dynamic>.from(job);
            final jobId = getMongoId(jobMap['_id']);
            jobMap['saved_at'] = savedAtByJobId[jobId];
            return jobMap;
          })
          .toList();

      result.sort((a, b) {
        final aIndex = savedJobIds.indexOf(getMongoId(a['_id']));
        final bIndex = savedJobIds.indexOf(getMongoId(b['_id']));
        return aIndex.compareTo(bIndex);
      });

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('Gagal mengambil lowongan tersimpan: $e');
      return [];
    }
  }
}