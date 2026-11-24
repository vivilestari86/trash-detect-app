
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> register({
    required String nama,
    required String email,
    required String password,
  }) {
    return remoteDataSource.register(
      nama: nama,
      email: email,
      password: password,
    );
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) {
    return remoteDataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<User> getProfile() {
    return remoteDataSource.getProfile();
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}
