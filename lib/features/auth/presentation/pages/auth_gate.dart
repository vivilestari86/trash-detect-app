
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/token_storage.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class AuthGate extends StatefulWidget {
  final TokenStorage tokenStorage;

  const AuthGate({
    super.key,
    required this.tokenStorage,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await widget.tokenStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      await context.read<AuthProvider>().loadProfile();
    }

    if (!mounted) return;

    setState(() {
      _checkingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isAuthenticated) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
