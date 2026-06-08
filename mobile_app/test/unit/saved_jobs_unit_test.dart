import 'package:flutter_test/flutter_test.dart';

// SavedJob utility untuk testing
class SavedJobManager {
  final List<Map<String, dynamic>> _savedJobs = [];

  /// Mendapatkan list saved jobs
  List<Map<String, dynamic>> getSavedJobs() {
    return List.from(_savedJobs);
  }

  /// Cek apakah job sudah tersimpan berdasarkan user_id dan job_id
  bool isJobSaved(String jobId, {String? userId}) {
    if (userId != null) {
      // Check combination of user_id and job_id
      return _savedJobs.any((job) =>
          job['user_id'] == userId &&
          (job['job_id'] == jobId || job['_id'] == jobId));
    }
    // Check only job_id
    return _savedJobs.any((job) => job['job_id'] == jobId || job['_id'] == jobId);
  }

  /// Menambah job ke saved jobs (tidak boleh duplikat untuk kombinasi user_id+job_id)
  bool addSavedJob({
    required String jobId,
    required String userId,
    Map<String, dynamic>? jobData,
  }) {
    // Check if already exists for this user+job combination
    if (isJobSaved(jobId, userId: userId)) {
      print('Job already saved');
      return false;
    }

    // Add new saved job
    final savedJob = {
      'job_id': jobId,
      'user_id': userId,
      'saved_at': DateTime.now().toIso8601String(),
      ...?jobData,
    };

    _savedJobs.add(savedJob);
    return true;
  }

  /// Menghapus job dari saved jobs berdasarkan kombinasi user_id dan job_id
  bool removeSavedJob({
    required String userId,
    required String jobId,
  }) {
    final initialLength = _savedJobs.length;

    // Remove based on combination of user_id and job_id
    _savedJobs.removeWhere((job) =>
        job['user_id'] == userId && (job['job_id'] == jobId || job['_id'] == jobId));

    return _savedJobs.length < initialLength;
  }

  /// Get saved jobs for specific user
  List<Map<String, dynamic>> getSavedJobsForUser(String userId) {
    return _savedJobs
        .where((job) => job['user_id'] == userId)
        .toList();
  }

  /// Clear all saved jobs
  void clearAll() {
    _savedJobs.clear();
  }
}

void main() {
  group('TC-UNIT-SAVED-001: Pengecekan Saved Job yang Sudah Ada', () {
    late SavedJobManager jobManager;

    setUp(() {
      jobManager = SavedJobManager();
    });

    test(
        'Positive Case - Tidak membuat duplikat ketika save job dengan job_id sama',
        () {
      const userId = 'user123';
      const jobId = 'job456';

      // First save
      final result1 = jobManager.addSavedJob(
        jobId: jobId,
        userId: userId,
        jobData: {'title': 'Developer', 'company': 'Tech Corp'},
      );

      expect(result1, true, reason: 'First save harus berhasil');
      expect(jobManager.getSavedJobs().length, 1,
          reason: 'Harus ada 1 saved job');

      // Try to save same job again
      final result2 = jobManager.addSavedJob(
        jobId: jobId,
        userId: userId,
        jobData: {'title': 'Developer', 'company': 'Tech Corp'},
      );

      expect(result2, false,
          reason:
              'Save job dengan job_id yang sama harus ditolak untuk mencegah duplikat');
      expect(jobManager.getSavedJobs().length, 1,
          reason: 'Tetap hanya ada 1 saved job, tidak duplikat');
    });

    test('Positive Case - Job dengan job_id berbeda boleh disave', () {
      const userId = 'user123';
      const jobId1 = 'job001';
      const jobId2 = 'job002';

      // Save first job
      final result1 = jobManager.addSavedJob(
        jobId: jobId1,
        userId: userId,
      );

      expect(result1, true, reason: 'Simpan job pertama harus berhasil');

      // Save different job
      final result2 = jobManager.addSavedJob(
        jobId: jobId2,
        userId: userId,
      );

      expect(result2, true, reason: 'Simpan job berbeda harus berhasil');
      expect(jobManager.getSavedJobs().length, 2,
          reason: 'Harus ada 2 saved job yang berbeda');
    });

    test('Positive Case - Check if job is saved', () {
      const jobId = 'job123';
      const userId = 'user1';

      jobManager.addSavedJob(jobId: jobId, userId: userId);

      final isSaved = jobManager.isJobSaved(jobId, userId: userId);

      expect(isSaved, true, reason: 'Job yang sudah disave harus terdeteksi');
    });

    test('Positive Case - Check if job not saved', () {
      const jobId = 'job999';
      const userId = 'user1';

      final isSaved = jobManager.isJobSaved(jobId, userId: userId);

      expect(isSaved, false,
          reason: 'Job yang belum disave harus terdeteksi sebagai not saved');
    });
  });

  group('TC-UNIT-SAVED-002: Pengecekan Unsave Job', () {
    late SavedJobManager jobManager;

    setUp(() {
      jobManager = SavedJobManager();
    });

    test('Positive Case - Menghapus lowongan dari saved jobs', () {
      const userId = 'user123';
      const jobId = 'job456';

      // Save a job first
      jobManager.addSavedJob(
        jobId: jobId,
        userId: userId,
        jobData: {'title': 'Developer', 'company': 'Tech Corp'},
      );

      expect(jobManager.getSavedJobs().length, 1,
          reason: 'Harus ada 1 saved job sebelum unsave');

      // Remove the job
      final result = jobManager.removeSavedJob(
        userId: userId,
        jobId: jobId,
      );

      expect(result, true, reason: 'Unsave job harus berhasil');
      expect(jobManager.getSavedJobs().length, 0,
          reason: 'Saved jobs harus kosong setelah unsave');
    });

    test(
        'Positive Case - Menghapus berdasarkan kombinasi user_id dan job_id',
        () {
      const userId1 = 'user123';
      const userId2 = 'user456';
      const jobId = 'job001';

      // Save same job for different users
      jobManager.addSavedJob(jobId: jobId, userId: userId1);
      jobManager.addSavedJob(jobId: jobId, userId: userId2);

      expect(jobManager.getSavedJobs().length, 2,
          reason: 'Harus ada 2 saved job dari 2 user berbeda');

      // Remove job for user1 only
      jobManager.removeSavedJob(userId: userId1, jobId: jobId);

      expect(jobManager.getSavedJobs().length, 1,
          reason: 'Harus tinggal 1 saved job untuk user2');

      // Verify user2 still has the job
      final user2Jobs = jobManager.getSavedJobsForUser(userId2);
      expect(user2Jobs.length, 1,
          reason: 'User2 masih harus punya 1 saved job');
    });

    test('Positive Case - Unsave multiple jobs independently', () {
      const userId = 'user123';
      const jobId1 = 'job001';
      const jobId2 = 'job002';
      const jobId3 = 'job003';

      // Save 3 jobs
      jobManager.addSavedJob(jobId: jobId1, userId: userId);
      jobManager.addSavedJob(jobId: jobId2, userId: userId);
      jobManager.addSavedJob(jobId: jobId3, userId: userId);

      expect(jobManager.getSavedJobs().length, 3,
          reason: 'Harus ada 3 saved job');

      // Remove middle job
      jobManager.removeSavedJob(userId: userId, jobId: jobId2);

      expect(jobManager.getSavedJobs().length, 2,
          reason: 'Harus tinggal 2 saved job setelah menghapus job2');

      // Verify job1 and job3 still exist
      expect(jobManager.isJobSaved(jobId1), true,
          reason: 'Job1 harus masih tersimpan');
      expect(jobManager.isJobSaved(jobId3), true,
          reason: 'Job3 harus masih tersimpan');
      expect(jobManager.isJobSaved(jobId2), false,
          reason: 'Job2 harus sudah dihapus');
    });

    test('Positive Case - Unsave job yang tidak ada tidak menimbulkan error', () {
      const userId = 'user123';
      const jobId = 'job_tidak_ada';

      // Try to remove job that doesn't exist
      expect(
        () {
          jobManager.removeSavedJob(userId: userId, jobId: jobId);
        },
        returnsNormally,
        reason: 'Unsave job tidak ada harus return tanpa error',
      );

      expect(jobManager.getSavedJobs().length, 0,
          reason: 'List tetap kosong');
    });

    test(
        'Positive Case - Menghapus unsave berdasarkan kombinasi user_id dan job_id',
        () {
      const userId1 = 'user_A';
      const userId2 = 'user_B';
      const jobId1 = 'job_001';

      // Add saved jobs
      jobManager.addSavedJob(jobId: jobId1, userId: userId1);
      jobManager.addSavedJob(jobId: jobId1, userId: userId2);

      // Remove for specific user only
      final result = jobManager.removeSavedJob(userId: userId1, jobId: jobId1);

      expect(result, true, reason: 'Removal harus berhasil');
      expect(
          jobManager.getSavedJobs()
              .where((job) => job['user_id'] == userId1)
              .length,
          0,
          reason: 'User1 tidak boleh punya job saved lagi');
      expect(
          jobManager.getSavedJobs()
              .where((job) => job['user_id'] == userId2)
              .length,
          1,
          reason: 'User2 masih harus punya job saved');
    });
  });
}
