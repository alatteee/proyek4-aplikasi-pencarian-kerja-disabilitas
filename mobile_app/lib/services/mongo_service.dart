import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static late Db db;
  static late DbCollection users;
  static late DbCollection userDetails;

  static Future<void> connect() async {
    final uri = dotenv.env['MONGODB_URI'];

    if (uri == null || uri.isEmpty) {
      throw Exception('MONGODB_URI tidak ditemukan');
    }

    if (_isDbOpen) return;

    db = await Db.create(uri);
    await db.open();

    users = db.collection('users');
    userDetails = db.collection('user_details');

    print('✅ MongoDB Connected');
  }

  static bool get _isDbOpen {
    try {
      return db.state == State.open;
    } catch (_) {
      return false;
    }
  }

  static Future<void> ensureConnected() async {
    if (!_isDbOpen) await connect();
  }

  static DbCollection get _jobVacanciesCollection =>
      db.collection('job_vacancies');
  static DbCollection get _savedJobsCollection => db.collection('saved_jobs');
  static DbCollection get _jobApplicationsCollection =>
      db.collection('job_applications');
  static DbCollection get _companiesCollection => db.collection('companies');

  static String getMongoId(dynamic value) {
    if (value == null) return '';
    if (value is ObjectId) return value.oid;
    return value.toString();
  }

  static Future<List<Map<String, dynamic>>> getJobVacancies() async {
    try {
      await ensureConnected();
      final jobs = await _jobVacanciesCollection
          .find(where.eq('status', 'active').sortBy('created_at', descending: true))
          .toList();
      return jobs.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Gagal mengambil data lowongan: $e');
      return [];
    }
  }

  static Future<bool> saveJob({
    required String userId,
    required String jobId,
  }) async {
    try {
      await ensureConnected();
      if (userId.isEmpty || jobId.isEmpty) return false;
      final existing =
          await _savedJobsCollection.findOne({'user_id': userId, 'job_id': jobId});
      if (existing != null) return true;
      await _savedJobsCollection.insertOne({
        'user_id': userId,
        'job_id': jobId,
        'saved_at': DateTime.now().toUtc(),
      });
      return true;
    } catch (e) {
      print('Gagal menyimpan lowongan: $e');
      return false;
    }
  }

  static Future<bool> unsaveJob({
    required String userId,
    required String jobId,
  }) async {
    try {
      await ensureConnected();
      if (userId.isEmpty || jobId.isEmpty) return false;
      await _savedJobsCollection.deleteOne({'user_id': userId, 'job_id': jobId});
      return true;
    } catch (e) {
      print('Gagal menghapus lowongan tersimpan: $e');
      return false;
    }
  }

  static Future<bool> isJobSaved({
    required String userId,
    required String jobId,
  }) async {
    try {
      await ensureConnected();
      if (userId.isEmpty || jobId.isEmpty) return false;
      final savedJob =
          await _savedJobsCollection.findOne({'user_id': userId, 'job_id': jobId});
      return savedJob != null;
    } catch (e) {
      print('Gagal mengecek lowongan tersimpan: $e');
      return false;
    }
  }

  static Future<Set<String>> getSavedJobIds({required String userId}) async {
    try {
      await ensureConnected();
      if (userId.isEmpty) return <String>{};
      final savedJobs =
          await _savedJobsCollection.find(where.eq('user_id', userId)).toList();
      return savedJobs
          .map((item) => item['job_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e) {
      print('Gagal mengambil id lowongan tersimpan: $e');
      return <String>{};
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedJobs({
    required String userId,
  }) async {
    try {
      await ensureConnected();
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

      final activeJobs =
          await _jobVacanciesCollection.find(where.eq('status', 'active')).toList();
      final result = activeJobs
          .where((job) => savedJobIds.contains(getMongoId(job['_id'])))
          .map<Map<String, dynamic>>((job) {
        final jobMap = Map<String, dynamic>.from(job);
        final jobId = getMongoId(jobMap['_id']);
        jobMap['saved_at'] = savedAtByJobId[jobId];
        return jobMap;
      }).toList();

      result.sort((a, b) {
        final aIndex = savedJobIds.indexOf(getMongoId(a['_id']));
        final bIndex = savedJobIds.indexOf(getMongoId(b['_id']));
        return aIndex.compareTo(bIndex);
      });
      return result;
    } catch (e) {
      print('Gagal mengambil lowongan tersimpan: $e');
      return [];
    }
  }

  static Future<bool> hasAppliedJob({
    required String userId,
    required String jobId,
  }) async {
    try {
      await ensureConnected();
      if (userId.isEmpty || jobId.isEmpty) return false;
      final existing =
          await _jobApplicationsCollection.findOne({'user_id': userId, 'job_id': jobId});
      return existing != null;
    } catch (e) {
      print('Gagal mengecek lamaran: $e');
      return false;
    }
  }

  static Future<bool> submitJobApplication({
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      await ensureConnected();
      final userId = applicationData['user_id']?.toString() ?? '';
      final jobId = applicationData['job_id']?.toString() ?? '';
      if (userId.isEmpty || jobId.isEmpty) return false;
      final alreadyApplied = await hasAppliedJob(userId: userId, jobId: jobId);
      if (alreadyApplied) return false;
      await _jobApplicationsCollection.insertOne(applicationData);
      return true;
    } catch (e) {
      print('Gagal mengirim lamaran: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserApplications({
    required String userId,
  }) async {
    try {
      await ensureConnected();
      if (userId.isEmpty) return [];
      final applications = await _jobApplicationsCollection
          .find(where.eq('user_id', userId).sortBy('created_at', descending: true))
          .toList();
      return applications.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Gagal mengambil data lamaran: $e');
      return [];
    }
  }

  // ================= COMPANY DASHBOARD =================

  static Future<Map<String, dynamic>?> getCompanyByName(
    String companyName,
  ) async {
    try {
      await ensureConnected();

      if (companyName.isEmpty) return null;

      final company = await _companiesCollection.findOne(
        where.eq('company_name', companyName),
      );

      return company;
    } catch (e) {
      print('Gagal mengambil data company: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getCompanyJobs({
    required String companyId,
  }) async {
    try {
      await ensureConnected();

      if (companyId.isEmpty) return [];

      final jobs = await _jobVacanciesCollection
          .find(
            where
                .eq('company_id', ObjectId.fromHexString(companyId))
                .sortBy('created_at', descending: true),
          )
          .toList();

      return jobs.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Gagal mengambil lowongan company: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCompanyApplicants({
    required String companyId,
  }) async {
    try {
      await ensureConnected();

      if (companyId.isEmpty) return [];

      final applicants = await _jobApplicationsCollection
          .find(
            where
                .eq('company_id', ObjectId.fromHexString(companyId))
                .sortBy('created_at', descending: true),
          )
          .toList();

      return applicants.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Gagal mengambil pelamar company: $e');
      return [];
    }
  }
}