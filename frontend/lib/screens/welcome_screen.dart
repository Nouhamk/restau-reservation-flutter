import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // En-tête avec logo
                _buildHeader(),
                
                // Photo et description du pub
                _buildPubPresentation(context),
                
                // Actions principales
                _buildActionButtons(context),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          // Logo avec effet doré
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.goldGradient,
              boxShadow: AppTheme.leatherShadow,
            ),
            child: const Icon(
              Icons.local_bar,
              size: 30,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          
          // Nom du restaurant
          const Text(
            'Les AL',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          
          // Sous-titre
          const Text(
            'Pub Anglais Authentique',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.creamWhite,
              letterSpacing: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPubPresentation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Photo du pub (placeholder avec icône)
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.backgroundDark,
                  AppTheme.primaryDark.withOpacity(0.8),
                ],
              ),
              border: Border.all(
                color: AppTheme.accentGold.withOpacity(0.5),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image du pub
                  Image.asset(
                    'images/image1.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // En cas d'erreur, afficher le placeholder
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.leatherBrown.withOpacity(0.6),
                              AppTheme.primaryDark.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_camera_outlined,
                                size: 60,
                                color: AppTheme.accentGold,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Intérieur du Pub',
                                style: TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Overlay dégradé subtil
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Description du pub
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.accentGold.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentGold.withOpacity(0.3),
                            AppTheme.accentGold.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history_edu,
                        color: AppTheme.accentGold,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Notre Histoire',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                
                // Texte de description
                const Text(
                  'Fondé en 1985, Les AL est bien plus qu\'un simple restaurant. '
                  'C\'est un véritable pub anglais qui a su préserver son authenticité '
                  'tout en s\'adaptant aux goûts modernes.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.creamWhite,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Reconnu pour son cadre idyllique alliant boiseries anciennes, '
                  'fauteuils en cuir et ambiance chaleureuse, notre établissement '
                  'vous propose une expérience culinaire unique dans une atmosphère '
                  'conviviale et raffinée.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.creamWhite,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                
                // Séparateur
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.accentGold.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                
                // Points forts
                _buildFeatureRow(Icons.stars, 'Cuisine traditionnelle & moderne'),
                const SizedBox(height: 14),
                _buildFeatureRow(Icons.wine_bar, 'Large sélection de bières & vins'),
                const SizedBox(height: 14),
                _buildFeatureRow(Icons.groups, 'Ambiance chaleureuse & conviviale'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.accentGold, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.creamWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Divider décoratif
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.accentGold.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'COMMENCER',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentGold.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bouton Réserver une table (principal)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Navigation vers l'écran de connexion pour réserver
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor: AppTheme.accentGold.withOpacity(0.6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_seat, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Réserver une table',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Boutons Connexion et Inscription côte à côte
          Row(
            children: [
              // Bouton Connexion
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentGold,
                      side: const BorderSide(
                        color: AppTheme.accentGold,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Bouton Inscription
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryBrown,
                      foregroundColor: AppTheme.creamWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Inscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
