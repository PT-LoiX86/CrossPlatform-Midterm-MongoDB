import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  String? _signedInUsername;

  void _handleLogin(String username) {
    setState(() => _signedInUsername = username);
  }

  void _handleLogout() {
    setState(() => _signedInUsername = null);
  }

  @override
  Widget build(BuildContext context) {
    final username = _signedInUsername;
    if (username == null) {
      return LoginScreen(onLogin: _handleLogin);
    }
    return HomeScreen(username: username, onLogout: _handleLogout);
  }
}
