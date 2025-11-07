import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/practical_info_section.dart';
import 'welcome_screen.dart';

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
              backgroundColor: const Color(0xFFD32F2F),
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
        body: Center(child: CircularProgressIndicator(color: AppTheme.softBlack)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // En-tête compact
              _buildHeader(),

              // Corps principal
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Services rapides
                    _buildSectionTitle('Services rapides'),
                    const SizedBox(height: 16),
                    _buildQuickActionsRow(),

                    const SizedBox(height: 32),

                    // Services principaux
                    _buildSectionTitle('Nos services'),
                    const SizedBox(height: 16),
                    _buildMainServiceCard(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Notre Carte',
                      description: 'Découvrez nos plats et boissons',
                      color: AppTheme.roseGold,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildMainServiceCard(
                      icon: Icons.event_available_rounded,
                      title: 'Réserver une Table',
                      description: 'Choisissez votre créneau idéal',
                      color: AppTheme.champagne,
                      onTap: () => _showComingSoon(),
                    ),
                    const SizedBox(height: 16),
                    _buildMainServiceCard(
                      icon: Icons.list_alt_rounded,
                      title: 'Mes Réservations',
                      description: 'Gérez vos réservations en cours',
                      color: AppTheme.sageGreen,
                      onTap: () => _showComingSoon(),
                    ),

                    const SizedBox(height: 32),

                    // Informations pratiques
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
          // Avatar avec gradient
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.roseGoldGradient,
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.deepNavy,
              child: Text(
                _currentUser?.nom?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.mediumGrey,
                  ),
                ),
                Text(
                  _currentUser?.nom ?? 'Utilisateur',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ],
            ),
          ),

          // Bouton déconnexion
          IconButton(
            icon: Icon(Icons.logout_rounded, color: AppTheme.roseGold),
            onPressed: _handleLogout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.phone_rounded,
            label: 'Appeler',
            onTap: () => _showComingSoon(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.location_on_rounded,
            label: 'Itinéraire',
            onTap: () => _showComingSoon(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.share_rounded,
            label: 'Partager',
            onTap: () => _showComingSoon(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppTheme.subtleCardGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightGrey,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.roseGold.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.roseGold.withOpacity(0.15),
                ),
                child: Icon(icon, color: AppTheme.roseGold, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainServiceCard({
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
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightGrey,
              width: 1.5,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              // Icône
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),

              // Flèche
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
      SnackBar(
        content: Text('Fonctionnalité à venir'),
        backgroundColor: AppTheme.softBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}