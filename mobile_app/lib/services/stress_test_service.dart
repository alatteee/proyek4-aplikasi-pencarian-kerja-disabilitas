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

          // HomePage membaca `job_type`, tapi data lama kamu juga punya `type`.
          'type': jobType,
          'job_type': jobType,

          // Sengaja null agar tidak tersaring kategori.
          // Data ini tetap muncul saat tab HomePage = "Semua".
          'category': null,

          'description': _faker.lorem.sentences(3).join(' '),

          // URL gambar dummy.
          // HomePage sudah dimodifikasi agar support Image.network.
          'job_photo':
              'https://picsum.photos/seed/${_faker.guid.guid()}/400/300',

          'created_at': DateTime.now().toUtc(),
          'updated_at': DateTime.now().toUtc(),

          // Harus active karena MongoService.getPublishedJobs()
          // saat ini mengambil status active.
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
  /// Ini menguji collection `users` dan `users_details`.
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

        final dummyUser = {
          '_id': userId,
          'username': username,
          'email': _faker.internet.email(),
          'password': 'hashed_password_dummy',
          'role': 'pencaker',
          'created_at': DateTime.now().toUtc(),
          'updated_at': DateTime.now().toUtc(),
          'is_stress_test_data': true,
        };

        final dummyProfile = {
          'user_id': userId,
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

  /// Membersihkan SEMUA data hasil stress test dari berbagai collection.
  ///
  /// `jobs` tetap ikut dibersihkan karena sebelumnya data dummy sempat masuk ke sana.
  static Future<void> cleanStressTestData() async {
    try {
      final isConnected = await MongoService.ensureConnected();

      if (!isConnected) {
        print('❌ MongoDB tidak tersambung. Cleanup dibatalkan.');
        return;
      }

      final collections = [
        'job_vacancies',
        'jobs',
        'users',
        'user_details',
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