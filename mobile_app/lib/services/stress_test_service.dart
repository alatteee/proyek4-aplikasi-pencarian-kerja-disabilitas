import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../services/mongo_service.dart';

class StressTestService {
  static final Faker _faker = Faker();

  /// Skenario 1: Menambahkan [count] jumlah lowongan kerja dummy ke MongoDB
  static Future<Map<String, dynamic>> seedJobs(int count) async {
    final startTime = DateTime.now();
    int successCount = 0;
    List<String> errors = [];

    print('🚀 Memulai Seeding $count data Lowongan Kerja...');

    try {
      // Pastikan koneksi stabil sebelum memulai loop masal
      await MongoService.ensureConnected();
      final collection = MongoService.db.collection('jobs');

      for (int i = 0; i < count; i++) {
        final dummyJob = {
          '_id': ObjectId(),
          'job_title': _faker.job.title(),
          'title': _faker.job.title(),
          'company_name': _faker.company.name(),
          'location': _faker.address.city(),
          'salary': 'Rp ${_faker.randomGenerator.integer(10, min: 3)}jt - ${_faker.randomGenerator.integer(20, min: 11)}jt',
          'type': _faker.randomGenerator.element(['Full-time', 'Part-time', 'Contract']),
          'description': _faker.lorem.sentences(3).join(' '),
          'job_photo': 'https://picsum.photos/seed/${_faker.guid.guid()}/400/300',
          'created_at': DateTime.now().toUtc(),
          'status': 'active',
          'is_stress_test_data': true,
        };

        try {
          await collection.insert(dummyJob);
          successCount++;
          print('✅ Progress: $successCount/$count data berhasil disisipkan');
        } catch (insertError) {
          print('⚠️ Gagal di item ke $i, mencoba reconnect...');
          await MongoService.ensureConnected();
          // Coba insert ulang sekali lagi setelah reconnect
          await collection.insert(dummyJob);
          successCount++;
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
      'errors': errors
    };
  }

  /// Skenario 2: Menambahkan [count] jumlah User Account & Profile dummy
  /// Ini menguji 'Auth' (users) dan 'Profile Detail' (users_details) sekaligus
  static Future<Map<String, dynamic>> seedUsers(int count) async {
    final startTime = DateTime.now();
    int successCount = 0;
    List<String> errors = [];

    print('👤 Memulai Seeding $count User & Profil...');

    try {
      final usersCollection = MongoService.db.collection('users');
      final detailsCollection = MongoService.db.collection('users_details');

      for (int i = 0; i < count; i++) {
        final userId = ObjectId();
        final username = _faker.internet.userName();
        
        // 1. Insert ke Tabel User (Auth)
        final dummyUser = {
          '_id': userId,
          'username': username,
          'email': _faker.internet.email(),
          'password': 'hashed_password_dummy', // Simulasi password
          'role': 'pencaker',
          'is_stress_test_data': true,
        };
        await usersCollection.insert(dummyUser);

        // 2. Insert ke Tabel UserDetails (Profil)
        final dummyProfile = {
          'user_id': userId,
          'nama_lengkap': _faker.person.name(),
          'phone': _faker.phoneNumber.us(),
          'jenis_kelamin': _faker.randomGenerator.element(['Laki-laki', 'Perempuan']),
          'jenis_disabilitas': _faker.randomGenerator.element(['Tunanetra', 'Tunarungu', 'Tunadaksa']),
          'skills': [_faker.job.title(), _faker.job.title()],
          'profile_photo': 'https://i.pravatar.cc/150?u=${userId.toHexString()}',
          'is_stress_test_data': true,
        };
        await detailsCollection.insert(dummyProfile);
        
        successCount++;
      }
    } catch (e) {
      errors.add(e.toString());
    }

    final duration = DateTime.now().difference(startTime);
    return {
      'total_requested': count,
      'success_count': successCount,
      'duration_ms': duration.inMilliseconds,
      'errors': errors
    };
  }

  /// Membersihkan SEMUA data hasil stress test dari berbagai koleksi
  static Future<void> cleanStressTestData() async {
    try {
      final collections = ['jobs', 'users', 'users_details'];
      for (var collName in collections) {
        final coll = MongoService.db.collection(collName);
        await coll.remove({'is_stress_test_data': true});
      }
      print('🧹 Berhasil membersihkan semua database dari data Stress Test.');
    } catch (e) {
      print('❌ Gagal membersihkan data: $e');
    }
  }
}
