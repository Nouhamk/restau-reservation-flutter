import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les AL - Restaurant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Thème lumineux et minimaliste
      home: const AuthenticationWrapper(),
    );
  }
}

/// Widget qui vérifie si l'utilisateur est connecté
/// et affiche l'écran approprié
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Vérifier si l'utilisateur est déjà connecté
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un loader pendant la vérification
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Icon(
                    Icons.local_bar,
                    size: 60,
                    color: AppTheme.deepNavy,
                  ),
                ),
                const SizedBox(height: 32),
                CircularProgressIndicator(
                  color: AppTheme.deepNavy,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    color: AppTheme.secondaryGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Rediriger vers l'écran approprié
    return _isLoggedIn ? const HomeScreen() : const WelcomeScreen();
  }
}
