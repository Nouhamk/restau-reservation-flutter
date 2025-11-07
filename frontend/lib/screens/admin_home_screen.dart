import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/practical_info_section.dart';
import 'welcome_screen.dart';
import 'admin_places_screen.dart';

/// Écran d'accueil pour les ADMINISTRATEURS
/// L'admin peut gérer les restaurants, menus et tout le système
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion',
            style: TextStyle(color: AppTheme.darkText)),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: AppTheme.mediumGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elegantBurgundy,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightBackground,
        body:
            Center(child: CircularProgressIndicator(color: AppTheme.deepNavy)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Administration'),
                    const SizedBox(height: 16),
                    _buildAdminServiceCard(
                      icon: Icons.restaurant_rounded,
                      title: 'Gérer les Restaurants',
                      description: 'Ajouter et modifier les restaurants',
                      color: AppTheme.deepNavy,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const AdminPlacesScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAdminServiceCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Gérer les Menus',
                      description: 'Éditer les cartes et les plats',
                      color: AppTheme.roseGold,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminServiceCard(
                      icon: Icons.people_rounded,
                      title: 'Gérer les Utilisateurs',
                      description: 'Clients, hôtes et administrateurs',
                      color: AppTheme.champagne,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminServiceCard(
                      icon: Icons.calendar_month_rounded,
                      title: 'Toutes les Réservations',
                      description: 'Vue globale des réservations',
                      color: AppTheme.sageGreen,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminServiceCard(
                      icon: Icons.analytics_outlined,
                      title: 'Statistiques & Rapports',
                      description: 'Analyse des performances',
                      color: AppTheme.elegantBurgundy,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminServiceCard(
                      icon: Icons.settings_rounded,
                      title: 'Paramètres Système',
                      description: 'Configuration globale',
                      color: AppTheme.secondaryGray,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 24),
                    _buildSystemStats(),
                    const SizedBox(height: 24),
                    PracticalInfoSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepNavy, AppTheme.deepNavy.withOpacity(0.8)],
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.roseGoldGradient,
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.roseGold,
              child: Text(
                _currentUser?.nom?.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administrateur',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _currentUser?.nom ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.deepNavy.withOpacity(0.15),
            AppTheme.roseGold.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepNavy.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.security_rounded, size: 40, color: AppTheme.deepNavy),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panneau d\'Administration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contrôle total du système',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGrey),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble du système',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('—', 'Restaurants', AppTheme.deepNavy),
              ),
              Container(width: 1, height: 40, color: AppTheme.lightGrey),
              Expanded(
                child: _buildStatItem('—', 'Clients', AppTheme.roseGold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.lightGrey),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('—', 'Hôtes', AppTheme.champagne),
              ),
              Container(width: 1, height: 40, color: AppTheme.lightGrey),
              Expanded(
                child: _buildStatItem('—', 'Réservations', AppTheme.sageGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAdminServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.lightGrey, width: 1.5),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
        backgroundColor: AppTheme.softBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
