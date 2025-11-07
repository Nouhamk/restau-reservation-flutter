import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

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
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.accentGold.withOpacity(0.3)),
        ),
        title: const Text(
          'Déconnexion',
          style: TextStyle(color: AppTheme.accentGold),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: AppTheme.creamWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warmRed,
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
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.accentGold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.goldGradient
              .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: const Text(
            'AU BUREAU',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.accentGold),
            onPressed: _handleLogout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carte de profil style cuir
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentGold.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: AppTheme.leatherShadow,
                ),
                child: Column(
                  children: [
                    // Avatar doré
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGold.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ligne décorative
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppTheme.accentGold.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.star,
                            color: AppTheme.accentGold.withOpacity(0.5),
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppTheme.accentGold.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bienvenue
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.goldGradient
                          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      child: const Text(
                        'BIENVENUE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nom
                    if (_currentUser?.nom != null && _currentUser!.nom!.isNotEmpty)
                      Text(
                        _currentUser!.nom!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.creamWhite,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 8),

                    // Email
                    Text(
                      _currentUser?.email ?? 'Aucun email',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.creamWhite.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Téléphone
                    if (_currentUser?.telephone != null &&
                        _currentUser!.telephone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppTheme.accentGold.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentUser!.telephone!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.creamWhite.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Message de succès
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.deepGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.deepGreen.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.accentGold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Connexion réussie !',
                        style: TextStyle(
                          color: AppTheme.creamWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section titre
              Text(
                'NOS SERVICES',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppTheme.accentGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Divider(
                color: AppTheme.accentGold.withOpacity(0.3),
                thickness: 1,
                indent: 100,
                endIndent: 100,
              ),
              const SizedBox(height: 24),

              // Boutons de navigation
              _buildNavigationButton(
                context,
                icon: Icons.restaurant_menu,
                title: 'Notre Carte',
                subtitle: 'Découvrez nos plats & boissons',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildNavigationButton(
                context,
                icon: Icons.calendar_today,
                title: 'Réserver une Table',
                subtitle: 'Choisissez votre créneau idéal',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildNavigationButton(
                context,
                icon: Icons.list_alt,
                title: 'Mes Réservations',
                subtitle: 'Gérez vos réservations en cours',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildNavigationButton(
                context,
                icon: Icons.info_outline,
                title: 'Informations',
                subtitle: 'Horaires, localisation, contact',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundDark,
            AppTheme.backgroundDark.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icône avec fond doré
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryDark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),

                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.creamWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.creamWhite.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Flèche
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppTheme.accentGold.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}