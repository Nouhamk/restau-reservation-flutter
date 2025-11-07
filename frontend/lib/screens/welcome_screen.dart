import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/practical_info_section.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
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
                
                // Informations pratiques
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: PracticalInfoSection(),
                ),
                
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            AppTheme.warmBeige.withOpacity(0.5),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          // Logo minimaliste avec couleur
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.roseGoldGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.roseGold.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_bar,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nom du restaurant élégant
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.roseGoldGradient.createShader(bounds),
            child: const Text(
              'Les AL',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Sous-titre sobre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Pub Anglais Authentique',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.deepNavy,
                letterSpacing: 3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Boutons de navigation
          _buildTopNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildTopNavigationButtons() {
    return Builder(
      builder: (context) => Row(
        children: [
          // Bouton Notre Carte avec dégradé
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.roseGoldGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.roseGold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MenuPage(),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Notre Carte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Bouton Réserver avec bordure colorée
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppTheme.deepNavy,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppTheme.deepNavy,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Réserver',
                        style: TextStyle(
                          color: AppTheme.deepNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF2C2C2C),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
                        color: const Color(0xFF2C2C2C),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_camera_outlined,
                                size: 48,
                                color: Color(0xFFB8B8B0),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Intérieur du Pub',
                                style: TextStyle(
                                  color: Color(0xFFB8B8B0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Overlay subtil
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.subtleCardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.lightGrey,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.roseGold.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre avec accent coloré
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: AppTheme.roseGoldGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notre Histoire',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.deepNavy,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Texte de description
                Text(
                  'Fondé en 1985, Les AL est bien plus qu\'un simple restaurant. '
                  'C\'est un véritable pub anglais qui a su préserver son authenticité '
                  'tout en s\'adaptant aux goûts modernes.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.secondaryGray,
                    height: 1.7,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Reconnu pour son cadre idyllique alliant boiseries anciennes, '
                  'fauteuils en cuir et ambiance chaleureuse, notre établissement '
                  'vous propose une expérience culinaire unique dans une atmosphère '
                  'conviviale et raffinée.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.secondaryGray,
                    height: 1.7,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Séparateur coloré
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.roseGold.withOpacity(0.3),
                        AppTheme.champagne.withOpacity(0.3),
                        AppTheme.roseGold.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Points forts avec icônes colorées
                _buildFeatureRow(Icons.restaurant_menu, 'Cuisine traditionnelle & moderne', AppTheme.roseGold),
                const SizedBox(height: 14),
                _buildFeatureRow(Icons.local_bar, 'Large sélection de bières & vins', AppTheme.champagne),
                const SizedBox(height: 14),
                _buildFeatureRow(Icons.people_outline, 'Ambiance chaleureuse & conviviale', AppTheme.sageGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          // Message d'appel à l'action sobre
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppTheme.subtleCardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.lightGrey,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.champagne.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icône minimaliste avec gradient
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.roseGoldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.roseGold.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Titre sobre
                Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.deepNavy,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Réservez une table et profitez\nd\'une expérience personnalisée',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryGray,
                    height: 1.6,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Bouton Inscription avec fond sombre (style cohérent avec Se connecter)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Créer mon compte',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                
                // Lien vers connexion avec style cohérent
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà membre ? ',
                      style: TextStyle(
                        color: AppTheme.secondaryGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppTheme.roseGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
