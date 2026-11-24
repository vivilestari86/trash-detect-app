
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

import 'features/scan/data/datasources/scan_remote_datasource.dart';
import 'features/scan/data/repositories/scan_repository_impl.dart';
import 'features/scan/domain/usecases/classify_image.dart';
import 'features/scan/domain/usecases/get_scan_history.dart';
import 'features/scan/presentation/providers/scan_provider.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

void main() {
  final tokenStorage = TokenStorage();

  final apiClient = ApiClient(
    client: http.Client(),
    tokenStorage: tokenStorage,
  );

  final authRemoteDataSource = AuthRemoteDataSource(
    apiClient,
    tokenStorage,
  );

  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource,
  );

  runApp(
    TrashDetectApp(
      tokenStorage: tokenStorage,
      authRepository: authRepository,
    ),
  );
}

class TrashDetectApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthRepositoryImpl authRepository;

  const TrashDetectApp({
    super.key,
    required this.tokenStorage,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final scanRepository = ScanRepositoryImpl(
              ScanRemoteDataSource(
                http.Client(),
                tokenStorage,
              ),
            );

            return ScanProvider(
              ClassifyImage(scanRepository),
              GetScanHistory(scanRepository),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            Login(authRepository),
            Register(authRepository),
            authRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Trash Detect App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
          ),
          useMaterial3: true,
        ),
        home: AuthGate(tokenStorage: tokenStorage),
      ),
    );
  }
}
