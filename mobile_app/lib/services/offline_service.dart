import 'package:hive_flutter/hive_flutter.dart';

class OfflineService {
  static const String jobsBoxName = 'offline_jobs';
  static const String applicationsBoxName = 'offline_applications';
  static const String savedJobsBoxName = 'offline_saved_jobs';
  static const String userProfileBoxName = 'offline_user_profile';       // Profil pencaker
  static const String userCVBoxName = 'offline_user_cv';                 // CV pencaker
  static const String companyProfileBoxName = 'offline_company_profile'; // Profil company
  static const String companyJobsBoxName = 'offline_company_jobs';
  static const String companyApplicantsBoxName = 'offline_company_applicants'; // Pelamar untuk company
  static const String pendingSyncBoxName = 'pending_sync';
  static const String settingsBoxName = 'app_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(jobsBoxName);
    await Hive.openBox(applicationsBoxName);
    await Hive.openBox(savedJobsBoxName);
    await Hive.openBox(userProfileBoxName);
    await Hive.openBox(userCVBoxName);
    await Hive.openBox(companyProfileBoxName);
    await Hive.openBox(companyJobsBoxName);
    await Hive.openBox(companyApplicantsBoxName);
    await Hive.openBox(pendingSyncBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // --- User Profile (Pencaker) ---
  static Map<String, dynamic>? getCachedUserProfile(String userId) {
    if (userId.isEmpty) return null;
    final box = Hive.box(userProfileBoxName);
    final data = box.get(userId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> cacheUserProfile(
    String userId,
    Map<String, dynamic> profile,
  ) async {
    if (userId.isEmpty) return;
    final box = Hive.box(userProfileBoxName);
    final data = _sanitizeForHive(profile);
    await box.put(userId, data);
  }

  // --- User CV ---
  static Map<String, dynamic>? getCachedUserCV(String userId) {
    if (userId.isEmpty) return null;
    final box = Hive.box(userCVBoxName);
    final data = box.get(userId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> cacheUserCV(String userId, Map<String, dynamic> cv) async {
    if (userId.isEmpty) return;
    final box = Hive.box(userCVBoxName);
    final data = _sanitizeForHive(cv);
    await box.put(userId, data);
  }

  // --- Company Profile ---
  static Map<String, dynamic>? getCachedCompanyProfile(String userId) {
    final box = Hive.box(companyProfileBoxName);
    final data = box.get(userId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> cacheCompanyProfile(
    String userId,
    Map<String, dynamic> profile,
  ) async {
    try {
      final box = Hive.box(companyProfileBoxName);
      final data = _sanitizeForHive(Map<String, dynamic>.from(profile));
      await box.put(userId, data);
      print('✅ cacheCompanyProfile: Cached profile for user=$userId');
    } catch (e) {
      print('❌ ERROR cacheCompanyProfile: $e');
    }
  }

  // --- Company Jobs ---
  static List<Map<String, dynamic>> getCachedCompanyJobs(String userId) {
    final box = Hive.box(companyJobsBoxName);
    final data = box.get(userId);
    if (data == null) return [];
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> cacheCompanyJobs(
    String userId,
    List<Map<String, dynamic>> jobs,
  ) async {
    try {
      final box = Hive.box(companyJobsBoxName);
      final castedJobs = jobs
          .map((job) => _sanitizeForHive(Map<String, dynamic>.from(job)))
          .toList();
      await box.put(userId, castedJobs);
      print('✅ cacheCompanyJobs: Cached ${castedJobs.length} jobs for user=$userId');
    } catch (e) {
      print('❌ ERROR cacheCompanyJobs: $e');
    }
  }

  // --- Company Applicants ---
  static List<Map<String, dynamic>> getCachedCompanyApplicants(String userId) {
    final box = Hive.box(companyApplicantsBoxName);
    final data = box.get(userId);
    if (data == null) return [];
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> cacheCompanyApplicants(
    String userId,
    List<Map<String, dynamic>> applicants,
  ) async {
    try {
      final box = Hive.box(companyApplicantsBoxName);
      final sanitized = applicants
          .map((applicant) => _sanitizeForHive(applicant))
          .toList();
      await box.put(userId, sanitized);
      print('✅ cacheCompanyApplicants: Cached ${sanitized.length} applicants');
    } catch (e) {
      print('❌ ERROR cacheCompanyApplicants: $e');
    }
  }

  // --- Jobs ---
  static List<Map<String, dynamic>> getCachedJobs() {
    final box = Hive.box(jobsBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> cacheJobs(List<Map<String, dynamic>> jobs) async {
    final box = Hive.box(jobsBoxName);
    await box.clear();

    for (var job in jobs) {
      final data = _sanitizeForHive(job);
      await box.add(data);
    }
  }

  // --- Saved Jobs ---
  static List<Map<String, dynamic>> getCachedSavedJobs(String userId) {
    if (userId.isEmpty) return [];

    try {
      final box = Hive.box(savedJobsBoxName);
      final data = box.get(userId);

      if (data == null) return [];

      return (data as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (e) {
      print('❌ Error getCachedSavedJobs: $e');
      return [];
    }
  }

  static Future<void> cacheSavedJobs(
    String userId,
    List<Map<String, dynamic>> savedJobs,
  ) async {
    if (userId.isEmpty) return;

    try {
      final box = Hive.box(savedJobsBoxName);

      final sanitizedJobs = savedJobs
          .map((job) => _sanitizeForHive(Map<String, dynamic>.from(job)))
          .toList();

      await box.put(userId, sanitizedJobs);

      print('✅ cacheSavedJobs: Cached ${sanitizedJobs.length} saved jobs for user=$userId');
    } catch (e) {
      print('❌ Error cacheSavedJobs: $e');
    }
  }

  static Set<String> getCachedSavedJobIds(String userId) {
    if (userId.isEmpty) return <String>{};

    try {
      final savedJobs = getCachedSavedJobs(userId);

      return savedJobs
          .map((job) => _extractId(job['_id'] ?? job['id'] ?? job['job_id']))
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e) {
      print('❌ Error getCachedSavedJobIds: $e');
      return <String>{};
    }
  }

  static Future<bool> addCachedSavedJob({
    required String userId,
    required String jobId,
    Map<String, dynamic>? jobData,
  }) async {
    if (userId.isEmpty || jobId.isEmpty) return false;

    try {
      final currentSavedJobs = getCachedSavedJobs(userId);

      final alreadyExists = currentSavedJobs.any((job) {
        final cachedJobId = _extractId(job['_id'] ?? job['id'] ?? job['job_id']);
        return cachedJobId == jobId;
      });

      if (alreadyExists) {
        print('💾 addCachedSavedJob: Job already exists in cache');
        return true;
      }

      Map<String, dynamic>? jobToSave;

      if (jobData != null && jobData.isNotEmpty) {
        jobToSave = Map<String, dynamic>.from(jobData);
      } else {
        final allCachedJobs = getCachedJobs();

        for (final job in allCachedJobs) {
          final cachedJobId = _extractId(job['_id'] ?? job['id'] ?? job['job_id']);

          if (cachedJobId == jobId) {
            jobToSave = Map<String, dynamic>.from(job);
            break;
          }
        }
      }

      if (jobToSave == null) {
        print('⚠️ addCachedSavedJob: Job detail not found in cache');
        return false;
      }

      jobToSave['saved_at'] = DateTime.now().toIso8601String();

      currentSavedJobs.insert(0, jobToSave);

      await cacheSavedJobs(userId, currentSavedJobs);

      print('✅ addCachedSavedJob: Job cached locally for user=$userId');
      return true;
    } catch (e) {
      print('❌ Error addCachedSavedJob: $e');
      return false;
    }
  }

  static Future<void> removeCachedSavedJob({
    required String userId,
    required String jobId,
  }) async {
    if (userId.isEmpty || jobId.isEmpty) return;

    try {
      final currentSavedJobs = getCachedSavedJobs(userId);

      currentSavedJobs.removeWhere((job) {
        final cachedJobId = _extractId(job['_id'] ?? job['id'] ?? job['job_id']);
        return cachedJobId == jobId;
      });

      await cacheSavedJobs(userId, currentSavedJobs);

      print('✅ removeCachedSavedJob: Job removed locally for user=$userId');
    } catch (e) {
      print('❌ Error removeCachedSavedJob: $e');
    }
  }

  // --- Applications ---
  static List<Map<String, dynamic>> getCachedApplications() {
    final box = Hive.box(applicationsBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> cacheApplications(
    List<Map<String, dynamic>> applications,
  ) async {
    final box = Hive.box(applicationsBoxName);
    await box.clear();

    for (var app in applications) {
      final data = _sanitizeForHive(app);
      await box.add(data);
    }
  }

  static Future<void> cachePendingApplication(
    Map<String, dynamic> applicationData,
  ) async {
    try {
      final box = Hive.box(applicationsBoxName);
      final data = _sanitizeForHive(applicationData);
      await box.add(data);
      print('✅ Pending application cached successfully.');
    } catch (e) {
      print('❌ Error caching pending application: $e');
    }
  }

  // Helper untuk membersihkan data dari tipe data MongoDB (ObjectId) yang tidak didukung Hive
  static Map<String, dynamic> _sanitizeForHive(Map<String, dynamic> rawData) {
    final Map<String, dynamic> sanitized = {};

    rawData.forEach((key, value) {
      if (value is Map) {
        sanitized[key] = _sanitizeForHive(Map<String, dynamic>.from(value));
      } else if (value is List) {
        sanitized[key] = value.map((e) {
          if (e is Map) return _sanitizeForHive(Map<String, dynamic>.from(e));
          if (e.runtimeType.toString().contains('ObjectId')) {
            return e.toString();
          }
          return e;
        }).toList();
      } else if (value.runtimeType.toString().contains('ObjectId')) {
        sanitized[key] = value.toString();
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  static String _extractId(dynamic value) {
    if (value == null) return '';

    final str = value.toString();

    final hexRegExp = RegExp(r'[0-9a-fA-F]{24}');
    final match = hexRegExp.firstMatch(str);

    if (match != null) {
      return match.group(0)!;
    }

    return str;
  }

  // --- Sync Queue ---
  static Future<void> addToSyncQueue(
    String action,
    Map<String, dynamic> data,
  ) async {
    final box = Hive.box(pendingSyncBoxName);

    final sanitizedData = _sanitizeForHive(data);

    await box.add({
      'action': action,
      'data': sanitizedData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>> getSyncQueue() {
    final box = Hive.box(pendingSyncBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> clearSyncQueue() async {
    await Hive.box(pendingSyncBoxName).clear();
  }

  // --- App Settings & Auth ---
  static bool get hasSeenOnboarding {
    final box = Hive.box(settingsBoxName);
    return box.get('hasSeenOnboarding', defaultValue: false);
  }

  static Future<void> setHasSeenOnboarding(bool value) async {
    final box = Hive.box(settingsBoxName);
    await box.put('hasSeenOnboarding', value);
  }

  static Map<String, dynamic>? getLoggedInUser() {
    final box = Hive.box(settingsBoxName);
    final data = box.get('loggedInUser');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> setLoggedInUser(Map<String, dynamic> user) async {
    final box = Hive.box(settingsBoxName);
    await box.put('loggedInUser', _sanitizeForHive(user));
  }

  static Future<void> clearLoggedInUser() async {
    final box = Hive.box(settingsBoxName);
    await box.delete('loggedInUser');
  }

  // --- Cache Management & Debugging ---
  /// Hapus cache jobs untuk memaksa fetch ulang dari MongoDB
  static Future<void> clearJobsCache() async {
    try {
      final box = Hive.box(jobsBoxName);
      await box.clear();
      print('✅ Jobs cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing jobs cache: $e');
    }
  }

  /// Hapus semua cache
  static Future<void> clearAllCache() async {
    try {
      await Hive.box(jobsBoxName).clear();
      await Hive.box(applicationsBoxName).clear();
      await Hive.box(savedJobsBoxName).clear();
      await Hive.box(userProfileBoxName).clear();
      await Hive.box(userCVBoxName).clear();
      await Hive.box(companyProfileBoxName).clear();
      await Hive.box(companyJobsBoxName).clear();
      await Hive.box(companyApplicantsBoxName).clear();
      await Hive.box(pendingSyncBoxName).clear();
      print('✅ All cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing all cache: $e');
    }
  }

  /// Debug: Tampilkan jumlah jobs yang di-cache
  static void debugCachedJobsCount() {
    final box = Hive.box(jobsBoxName);
    print('📊 DEBUG: Total cached jobs: ${box.length}');

    if (box.isNotEmpty) {
      final firstJob = box.values.first as Map;
      print('📊 DEBUG: First job has job_photo: ${firstJob.containsKey('job_photo')}');

      if (firstJob.containsKey('job_photo')) {
        final photoLength = firstJob['job_photo']?.toString().length ?? 0;
        print('📊 DEBUG: job_photo field size: $photoLength bytes');
      }
    }
  }
}