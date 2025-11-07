import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'client_home_screen.dart';
import 'host_home_screen.dart';
import 'admin_home_screen.dart';
import 'welcome_screen.dart';


/// Routeur qui redirige vers le bon écran d'accueil selon le rôle de l'utilisateur
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUser();
    if (user == null) {
      // Pas connecté => retour Welcome
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
      return;
    }
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Widget _buildRoleScreen() {
    final role = _currentUser?.role?.toLowerCase() ?? 'client';
    switch (role) {
      case 'admin':
      case 'administrateur':
        return const AdminHomeScreen();
      case 'host':
      case 'hote':
      case 'hôte':
        return const HostHomeScreen();
      case 'client':
      case 'customer':
      default:
        return const ClientHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.roseGoldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.roseGold.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_bar, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 28),
              CircularProgressIndicator(color: AppTheme.roseGold, strokeWidth: 2),
              const SizedBox(height: 12),
              Text(
                'Chargement du profil...',
                style: TextStyle(
                  color: AppTheme.secondaryGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Affiche directement l'écran adapté au rôle sans nouvelle navigation
    return _buildRoleScreen();
  }
}