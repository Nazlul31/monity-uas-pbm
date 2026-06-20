import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthHelper {
  AuthHelper._();

  /// Hash password menggunakan SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifikasi password dengan hash
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}
