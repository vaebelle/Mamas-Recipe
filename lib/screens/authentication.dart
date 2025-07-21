import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mama_recipe/services/auth_service.dart';
import 'package:mama_recipe/screens/login.dart';
import 'package:mama_recipe/screens/home.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    setState(() {
      _isDarkMode = SharedPreferencesHelper.instance.isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: StreamBuilder<User?>(
        stream: authService.value.authStateChanges,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return CupertinoPageScaffold(
              backgroundColor: _isDarkMode
                  ? const Color(0xFF1C1C1E)
                  : CupertinoColors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 50,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Authentication Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please restart the app',
                      style: TextStyle(
                        color: _isDarkMode
                            ? const Color(0xFFAEAEB2)
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // If user is logged in, show home page
          if (snapshot.hasData && snapshot.data != null) {
            return const HomePage();
          }

          // If user is not logged in, show login page
          return const Login();
        },
      ),
    );
  }
}
