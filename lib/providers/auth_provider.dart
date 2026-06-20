import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/database/database_helper.dart';
import '../core/utils/auth_helper.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Cek session tersimpan (dipanggil saat splash)
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return false;

    final user = await DatabaseHelper.instance.getUserById(userId);
    if (user == null) return false;

    _currentUser = user;
    notifyListeners();
    return true;
  }

  /// Registrasi akun baru
  Future<String?> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validasi duplikat email
      if (await DatabaseHelper.instance.isEmailTaken(email)) {
        _errorMessage = 'Email sudah digunakan oleh akun lain.';
        return _errorMessage;
      }

      // Validasi duplikat username
      if (await DatabaseHelper.instance.isUsernameTaken(username)) {
        _errorMessage = 'Username sudah digunakan oleh akun lain.';
        return _errorMessage;
      }

      final newUser = UserModel(
        fullName: fullName.trim(),
        username: username.trim(),
        email: email.trim().toLowerCase(),
        passwordHash: AuthHelper.hashPassword(password),
        createdAt: DateTime.now(),
      );

      final insertedId = await DatabaseHelper.instance.insertUser(newUser);

      // Seed demo data untuk akun baru
      await DatabaseHelper.instance.insertDemoTransactions(insertedId);

      // Auto login setelah registrasi
      final insertedUser = await DatabaseHelper.instance.getUserById(insertedId);
      _currentUser = insertedUser;

      // Simpan session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', insertedId);

      return null; // null = sukses
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login dengan email atau username
  Future<String?> login({
    required String emailOrUsername,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await DatabaseHelper.instance
          .getUserByEmailOrUsername(emailOrUsername.trim());

      if (user == null) {
        _errorMessage = 'Akun tidak ditemukan. Periksa kembali email atau username.';
        return _errorMessage;
      }

      if (!AuthHelper.verifyPassword(password, user.passwordHash)) {
        _errorMessage = 'Password salah. Silakan coba lagi.';
        return _errorMessage;
      }

      _currentUser = user;

      // Simpan session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

      return null; // null = sukses
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout — hapus session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update profil pengguna
  Future<String?> updateProfile({
    required String fullName,
    required String username,
    String? profileImagePath,
  }) async {
    if (_currentUser == null) return 'Tidak ada pengguna yang login.';

    _isLoading = true;
    notifyListeners();

    try {
      // Cek username apakah sudah dipakai orang lain
      if (username != _currentUser!.username) {
        if (await DatabaseHelper.instance.isUsernameTaken(username)) {
          _isLoading = false;
          notifyListeners();
          return 'Username sudah digunakan oleh akun lain.';
        }
      }

      final updated = _currentUser!.copyWith(
        fullName: fullName.trim(),
        username: username.trim(),
        profileImagePath: profileImagePath ?? _currentUser!.profileImagePath,
      );

      await DatabaseHelper.instance.updateUser(updated);
      _currentUser = updated;
      return null;
    } catch (e) {
      return 'Terjadi kesalahan saat menyimpan profil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ubah password
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return 'Tidak ada pengguna yang login.';

    if (!AuthHelper.verifyPassword(oldPassword, _currentUser!.passwordHash)) {
      return 'Password lama tidak sesuai.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final updated = _currentUser!.copyWith(
        passwordHash: AuthHelper.hashPassword(newPassword),
      );
      await DatabaseHelper.instance.updateUser(updated);
      _currentUser = updated;
      return null;
    } catch (e) {
      return 'Terjadi kesalahan saat mengubah password.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
