import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../services/mongo_service.dart';

class StressTestService {
  static final Faker _faker = Faker();

  /// Skenario 1: Menambahkan [count] jumlah lowongan kerja dummy ke MongoDB.
  ///
  /// Penting:
  /// HomePage membaca data dari collection `job_vacancies`,
  /// jadi data stress test juga harus masuk ke `job_vacancies`,
  /// bukan ke collection `jobs`.
  static Future<Map<String, dynamic>> seedJobs(int count) async {
    final startTime = DateTime.now();
    int successCount = 0;
    final List<String> errors = [];

    print('🚀 Memulai Seeding $count data Lowongan Kerja...');

    try {
      final isConnected = await MongoService.ensureConnected();

      if (!isConnected) {
        final message = 'MongoDB tidak tersambung. Seeding dibatalkan.';
        print('❌ $message');

        return {
          'total_requested': count,
          'success_count': successCount,
          'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          'errors': [message],
        };
      }

      final collection = MongoService.db.collection('job_vacancies');

      for (int i = 0; i < count; i++) {
        final jobType = _faker.randomGenerator.element([
          'Full-time',
          'Part-time',
          'Contract',
        ]);

        final title = _faker.job.title();

        final dummyJob = {
          '_id': ObjectId(),

          // Kompatibel dengan beberapa bagian UI/service
          'job_title': title,
          'title': title,

          'company_name': _faker.company.name(),
          'location': _faker.address.city(),
          'salary':
              'Rp ${_faker.randomGenerator.integer(10, min: 3)}jt - ${_faker.randomGenerator.integer(20, min: 11)}jt',

          // HomePage membaca `job_type`, tapi data lama juga punya `type`.
          'type': jobType,
          'job_type': jobType,

          // Sengaja null agar tidak tersaring kategori.
          // Data ini tetap muncul saat tab HomePage = "Semua".
          'category': null,

          'description': _faker.lorem.sentences(3).join(' '),

          // URL gambar dummy.
          // HomePage sudah support Image.network.
          'job_photo':
              'https://picsum.photos/seed/${_faker.guid.guid()}/400/300',

          'created_at': DateTime.now().toUtc(),
          'updated_at': DateTime.now().toUtc(),

          // Harus active karena MongoService.getPublishedJobs()
          // mengambil status active.
          'status': 'active',

          'applicant_count': 0,

          // Flag penting untuk cleanup dan identifikasi data dummy.
          'is_stress_test_data': true,
        };

        try {
          await collection.insert(dummyJob);
          successCount++;

          print('✅ Progress: $successCount/$count data berhasil disisipkan');
        } catch (insertError) {
          print('⚠️ Gagal di item ke-$i: $insertError');
          print('🔁 Mencoba reconnect dan insert ulang...');

          try {
            final reconnected = await MongoService.ensureConnected();

            if (!reconnected) {
              final message =
                  'Reconnect gagal pada item ke-$i. Data dilewati.';
              print('❌ $message');
              errors.add(message);
              continue;
            }

            await collection.insert(dummyJob);
            successCount++;

            print(
              '✅ Retry berhasil: $successCount/$count data berhasil disisipkan',
            );
          } catch (retryError) {
            final message = 'Retry gagal pada item ke-$i: $retryError';
            print('❌ $message');
            errors.add(message);
          }
        }
      }
    } catch (e) {
      print('❌ Error fatal saat seeding jobs: $e');
      errors.add(e.toString());
    }

    final duration = DateTime.now().difference(startTime);

    return {
      'total_requested': count,
      'success_count': successCount,
      'duration_ms': duration.inMilliseconds,
      'errors': errors,
    };
  }

  /// Skenario 2: Menambahkan [count] jumlah User Account & Profile dummy.
  ///
  /// Ini menguji collection `users` dan `user_details`.
  static Future<Map<String, dynamic>> seedUsers(int count) async {
    final startTime = DateTime.now();
    int successCount = 0;
    final List<String> errors = [];

    print('👤 Memulai Seeding $count User & Profil...');

    try {
      final isConnected = await MongoService.ensureConnected();

      if (!isConnected) {
        final message = 'MongoDB tidak tersambung. Seeding users dibatalkan.';
        print('❌ $message');

        return {
          'total_requested': count,
          'success_count': successCount,
          'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          'errors': [message],
        };
      }

      final usersCollection = MongoService.db.collection('users');
      final detailsCollection = MongoService.db.collection('user_details');

      for (int i = 0; i < count; i++) {
        final userId = ObjectId();
        final username = _faker.internet.userName();
        final email = _faker.internet.email();

        final dummyUser = {
          '_id': userId,
          'username': username,
          'email': email,
          'password': 'hashed_password_dummy',
          'password_hash': 'hashed_password_dummy',
          'role': 'pencaker',
          'created_at': DateTime.now().toUtc(),
          'updated_at': DateTime.now().toUtc(),
          'is_stress_test_data': true,
        };

        final dummyProfile = {
          'user_id': userId,
          'email': email,
          'username': username,
          'nama_lengkap': _faker.person.name(),
          'phone': _faker.phoneNumber.us(),
          'jenis_kelamin': _faker.randomGenerator.element([
            'Laki-laki',
            'Perempuan',
          ]),
          'jenis_disabilitas': _faker.randomGenerator.element([
            'Tunanetra',
            'Tunarungu',
            'Tunadaksa',
          ]),
          'skills': [
            _faker.job.title(),
            _faker.job.title(),
          ],
          'profile_photo': 'https://i.pravatar.cc/150?u=${userId.toHexString()}',
          'created_at': DateTime.now().toUtc(),
          'updated_at': DateTime.now().toUtc(),
          'is_stress_test_data': true,
        };

        try {
          await usersCollection.insert(dummyUser);
          await detailsCollection.insert(dummyProfile);

          successCount++;
          print('✅ Progress user: $successCount/$count berhasil disisipkan');
        } catch (insertError) {
          final message = 'Gagal insert user/profile item ke-$i: $insertError';
          print('❌ $message');
          errors.add(message);
        }
      }
    } catch (e) {
      print('❌ Error fatal saat seeding users: $e');
      errors.add(e.toString());
    }

    final duration = DateTime.now().difference(startTime);

    return {
      'total_requested': count,
      'success_count': successCount,
      'duration_ms': duration.inMilliseconds,
      'errors': errors,
    };
  }

  /// Skenario 3: Menambahkan [count] jumlah aplikasi lamaran
  /// dari user berbeda ke 1 lowongan yang sama.
  static Future<Map<String, dynamic>> seedApplications({
    required int count,
    required String jobId,
  }) async {
    final startTime = DateTime.now();
    int successCount = 0;
    final List<String> errors = [];

    print('📋 Memulai Seeding $count Aplikasi Lamaran ke Job: $jobId...');

    try {
      final isConnected = await MongoService.ensureConnected();

      if (!isConnected) {
        final message =
            'MongoDB tidak tersambung. Seeding applications dibatalkan.';
        print('❌ $message');

        return {
          'total_requested': count,
          'success_count': successCount,
          'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          'errors': [message],
        };
      }

      final applicationsCollection =
          MongoService.db.collection('job_applications');
      final usersCollection = MongoService.db.collection('users');
      final jobsCollection = MongoService.db.collection('job_vacancies');

      dynamic parsedJobId = jobId;

      try {
        parsedJobId = ObjectId.fromHexString(jobId);
      } catch (_) {
        parsedJobId = jobId;
      }

      final targetJob = await jobsCollection.findOne(where.id(parsedJobId));

      if (targetJob == null) {
        final message =
            'Job dengan ID $jobId tidak ditemukan di collection job_vacancies.';
        print('⚠️ $message');

        return {
          'total_requested': count,
          'success_count': 0,
          'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          'errors': [message],
        };
      }

      final dummyUsers = await usersCollection
          .find(where.eq('is_stress_test_data', true))
          .toList()
          .then((list) => list.take(count).toList());

      if (dummyUsers.isEmpty) {
        final message =
            'Tidak ada user dummy. Jalankan Stress Test (20 Users) terlebih dahulu.';
        print('⚠️ $message');

        return {
          'total_requested': count,
          'success_count': 0,
          'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          'errors': [message],
        };
      }

      for (var i = 0; i < dummyUsers.length; i++) {
        final userId = dummyUsers[i]['_id'];
        final userName = dummyUsers[i]['username'] ?? 'User $i';

        final alreadyApplied = await applicationsCollection.findOne(
          where.eq('user_id', userId).eq('job_id', parsedJobId),
        );

        if (alreadyApplied != null) {
          final message = 'User $userName sudah punya lamaran ke job ini.';
          print('⚠️ $message');
          errors.add(message);
          continue;
        }

        final now = DateTime.now().toUtc();

        final dummyApplication = {
          '_id': ObjectId(),
          'job_id': parsedJobId,
          'user_id': userId,
          'status': 'pending',
          'created_at': now,
          'applied_at': now,
          'updated_at': now,
          'cv_attachment': 'https://example.com/cv/$userId.pdf',
          'cover_letter': _faker.lorem.sentences(5).join(' '),
          'is_stress_test_data': true,
        };

        try {
          await applicationsCollection.insert(dummyApplication);

          try {
            await jobsCollection.updateOne(
              where.id(parsedJobId),
              modify.inc('applicant_count', 1).set(
                    'updated_at',
                    DateTime.now().toUtc(),
                  ),
            );
          } catch (counterError) {
            print('⚠️ Gagal update applicant_count: $counterError');
          }

          successCount++;
          print(
            '✅ Progress aplikasi: $successCount/${dummyUsers.length} dari $userName',
          );
        } catch (error) {
          final errorMsg = 'Gagal aplikasi user ke-$i: $error';
          print('❌ $errorMsg');
          errors.add(errorMsg);
        }
      }
    } catch (e) {
      print('❌ Error fatal saat seeding applications: $e');
      errors.add(e.toString());
    }

    final duration = DateTime.now().difference(startTime);

    return {
      'total_requested': count,
      'success_count': successCount,
      'duration_ms': duration.inMilliseconds,
      'errors': errors,
    };
  }

  /// Membersihkan SEMUA data hasil stress test dari berbagai collection.
  ///
  /// `jobs` tetap ikut dibersihkan karena sebelumnya data dummy sempat masuk ke sana.
  /// Cleanup juga mengurangi lagi applicant_count dari job asli
  /// yang dipakai saat stress test pelamar.
  static Future<void> cleanStressTestData() async {
    try {
      final isConnected = await MongoService.ensureConnected();

      if (!isConnected) {
        print('❌ MongoDB tidak tersambung. Cleanup dibatalkan.');
        return;
      }

      final jobsCollection = MongoService.db.collection('job_vacancies');
      final applicationsCollection =
          MongoService.db.collection('job_applications');

      // Hitung dulu jumlah dummy application per job_id
      // supaya applicant_count bisa dikurangi lagi saat cleanup.
      final dummyApplications = await applicationsCollection
          .find(where.eq('is_stress_test_data', true))
          .toList();

      final Map<dynamic, int> dummyApplicationCountByJobId = {};

      for (final application in dummyApplications) {
        final jobId = application['job_id'];

        if (jobId == null) continue;

        dummyApplicationCountByJobId[jobId] =
            (dummyApplicationCountByJobId[jobId] ?? 0) + 1;
      }

      // Kurangi applicant_count sesuai jumlah dummy application.
      for (final entry in dummyApplicationCountByJobId.entries) {
        final jobId = entry.key;
        final dummyCount = entry.value;

        try {
          final job = await jobsCollection.findOne(where.id(jobId));

          if (job == null) {
            print(
              '⚠️ Job $jobId tidak ditemukan saat update applicant_count cleanup.',
            );
            continue;
          }

          final currentApplicantCount = job['applicant_count'];

          int safeCurrentCount = 0;

          if (currentApplicantCount is int) {
            safeCurrentCount = currentApplicantCount;
          } else if (currentApplicantCount is num) {
            safeCurrentCount = currentApplicantCount.toInt();
          } else if (currentApplicantCount != null) {
            safeCurrentCount =
                int.tryParse(currentApplicantCount.toString()) ?? 0;
          }

          final newApplicantCount =
              (safeCurrentCount - dummyCount).clamp(0, safeCurrentCount);

          await jobsCollection.updateOne(
            where.id(jobId),
            modify
                .set('applicant_count', newApplicantCount)
                .set('updated_at', DateTime.now().toUtc()),
          );

          print(
            '🔢 applicant_count job $jobId dikurangi $dummyCount: $safeCurrentCount -> $newApplicantCount',
          );
        } catch (counterError) {
          print(
            '⚠️ Gagal mengurangi applicant_count untuk job $jobId: $counterError',
          );
        }
      }

      final collections = [
        'job_vacancies',
        'jobs',
        'users',
        'user_details',
        'job_applications',
        'notifications',
        'saved_jobs',
      ];

      for (final collName in collections) {
        final coll = MongoService.db.collection(collName);

        final result = await coll.remove({
          'is_stress_test_data': true,
        });

        print('🧹 Cleanup $collName selesai: $result');
      }

      print('✅ Berhasil membersihkan semua data Stress Test.');
    } catch (e) {
      print('❌ Gagal membersihkan data stress test: $e');
    }
  }
}