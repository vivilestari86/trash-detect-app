
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String nama,
    required String email,
    required String password,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> getProfile();

  Future<void> logout();
}
