
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final Login _login;
  final Register _register;
  final AuthRepository _repository;

  AuthProvider(
    this._login,
    this._register,
    this._repository,
  );

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _login(
        email: email,
        password: password,
      );

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Login gagal. Silakan coba kembali.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _register(
        nama: nama,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Registrasi gagal. Silakan coba kembali.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  
  Future<void> loadProfile() async {
    try {
      _user = await _repository.getProfile();
      _isAuthenticated = true;
      _errorMessage = null;
    } catch (_) {
      await _repository.logout();
      _user = null;
      _isAuthenticated = false;
    }

    notifyListeners();
  }


  Future<void> logout() async {
    await _repository.logout();

    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
