import 'package:flutter_test/flutter_test.dart';
import 'package:trash_detect_app/main.dart';
import 'package:trash_detect_app/core/network/api_client.dart';
import 'package:trash_detect_app/core/storage/token_storage.dart';
import 'package:trash_detect_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:trash_detect_app/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:http/http.dart' as http;

void main() {
  testWidgets('Trash Detect app smoke test', (WidgetTester tester) async {
    final tokenStorage = TokenStorage();

    final apiClient = ApiClient(
      client: http.Client(),
      tokenStorage: tokenStorage,
    );

    final remoteDataSource = AuthRemoteDataSource(
      apiClient,
      tokenStorage,
    );

    final authRepository = AuthRepositoryImpl(
      remoteDataSource,
    );

    await tester.pumpWidget(
      TrashDetectApp(
        tokenStorage: tokenStorage,
        authRepository: authRepository,
      ),
    );

    await tester.pump();

    expect(find.byType(TrashDetectApp), findsOneWidget);
  });
}