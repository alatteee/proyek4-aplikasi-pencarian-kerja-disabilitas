import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../services/mongo_service.dart';

class AuthController {
  
  // Method untuk Hash Password
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Cek apakah Email sudah terdaftar
  static Future<bool> isEmailExists(String email) async {
    try {
      final user = await MongoService.users.findOne({'email': email});
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Cek apakah Phone sudah terdaftar
  static Future<bool> isPhoneExists(String phone) async {
    try {
      final user = await MongoService.users.findOne({'phone': phone});
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Logic Sign Up
  static Future<String?> signUp({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      // 1. Cek Email & Phone duplication
      if (await isEmailExists(email)) {
        return 'Email sudah terdaftar. Gunakan email lain.';
      }
      if (await isPhoneExists(phone)) {
        return 'Nomor HP sudah terdaftar. Gunakan nomor lain.';
      }

      // 2. Hash Password
      final passwordHash = hashPassword(password);
      
      // 3. Insert Database
      await MongoService.users.insertOne({
        "username": username,
        "email": email,
        "phone": phone,
        "password_hash": passwordHash,
        "role": role,
        "created_at": DateTime.now(),
        "updated_at": DateTime.now()
      });

      return null; // Return null jika sukses
    } catch (e) {
      return 'Gagal melakukan pendaftaran: \'$e\'';
    } 
  }

  // Logic Login
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final passwordHash = hashPassword(password);
      final user = await MongoService.users.findOne({
        'email': email,
        'password_hash': passwordHash,
      });
      return user; // Return map data user jika ada, null jika salah
    } catch (e) {
      return null;
    }
  }
}
