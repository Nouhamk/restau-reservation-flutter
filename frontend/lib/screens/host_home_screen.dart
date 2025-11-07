import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/practical_info_section.dart';
import 'welcome_screen.dart';
import 'host_reservations_screen.dart';

/// Écran d'accueil pour les HÔTES
/// L'hôte peut gérer les réservations et le plan de table
class HostHomeScreen extends StatefulWidget {
  const HostHomeScreen({Key? key}) : super(key: key);

  @override
  State<HostHomeScreen> createState() => _HostHomeScreenState();
}

class _HostHomeScreenState extends State<HostHomeScreen> {
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
        title: const Text('Déconnexion', style: TextStyle(color: AppTheme.darkText)),
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
        body: Center(child: CircularProgressIndicator(color: AppTheme.deepNavy)),
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
                    _buildSectionTitle('Gestion du restaurant'),
                    const SizedBox(height: 16),
                    _buildHostServiceCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Gérer les Réservations',
                      description: 'Voir et confirmer les réservations',
                      color: AppTheme.champagne,
                      badge: '5 nouvelles',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HostReservationsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildHostServiceCard(
                      icon: Icons.table_restaurant_rounded,
                      title: 'Plan de Table',
                      description: 'Organiser les tables et placements',
                      color: AppTheme.sageGreen,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildHostServiceCard(
                      icon: Icons.schedule_rounded,
                      title: 'Créneaux Horaires',
                      description: 'Gérer la disponibilité des tables',
                      color: AppTheme.deepNavy,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildHostServiceCard(
                      icon: Icons.people_outline_rounded,
                      title: 'Liste des Clients',
                      description: 'Voir les clients et leurs préférences',
                      color: AppTheme.roseGold,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
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
        color: AppTheme.lightSurface,
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
              backgroundColor: AppTheme.champagne,
              child: Text(
                _currentUser?.nom?.substring(0, 1).toUpperCase() ?? 'H',
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
                  'Espace Hôte',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.mediumGrey,
                  ),
                ),
                Text(
                  _currentUser?.nom ?? 'Hôte',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.champagne),
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
          colors: [AppTheme.champagne.withOpacity(0.15), AppTheme.sageGreen.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.champagne.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined, size: 40, color: AppTheme.champagne),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tableau de Bord Hôte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gérez vos réservations et tables',
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

  Widget _buildQuickStats() {
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
            'Statistiques du jour',
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
                child: _buildStatItem('12', 'Réservations', AppTheme.champagne),
              ),
              Container(width: 1, height: 40, color: AppTheme.lightGrey),
              Expanded(
                child: _buildStatItem('8', 'Confirmées', AppTheme.sageGreen),
              ),
              Container(width: 1, height: 40, color: AppTheme.lightGrey),
              Expanded(
                child: _buildStatItem('4', 'En attente', AppTheme.roseGold),
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

  Widget _buildHostServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    String? badge,
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
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.elegantBurgundy,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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