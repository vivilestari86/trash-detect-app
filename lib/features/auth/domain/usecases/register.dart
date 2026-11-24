
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<User> call({
    required String nama,
    required String email,
    required String password,
  }) {
    return repository.register(
      nama: nama,
      email: email,
      password: password,
    );
  }
}
