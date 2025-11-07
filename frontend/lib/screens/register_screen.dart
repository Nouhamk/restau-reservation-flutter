import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nom: _nomController.text.trim().isNotEmpty ? _nomController.text.trim() : null,
      telephone: _telephoneController.text.trim().isNotEmpty
          ? _telephoneController.text.trim()
          : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppTheme.sageGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppTheme.elegantBurgundy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo minimaliste avec gradient
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.roseGoldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.roseGold.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_bar,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Titre élégant avec couleur - Nom du restaurant
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.roseGoldGradient.createShader(bounds),
                      child: const Text(
                        'Les AL',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 8,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Pub Anglais Authentique',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 3,
                        color: AppTheme.secondaryGray,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    Divider(
                      color: AppTheme.borderColor,
                      thickness: 1,
                      indent: 100,
                      endIndent: 100,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Inscription',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.secondaryGray,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Rejoignez la communauté',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.mediumGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Carte d'inscription
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.subtleCardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.roseGold.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email *',
                            hint: 'votre@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email requis';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Nom
                          CustomTextField(
                            controller: _nomController,
                            label: 'Nom complet',
                            hint: 'Jean Dupont',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),

                          // Téléphone
                          CustomTextField(
                            controller: _telephoneController,
                            label: 'Téléphone',
                            hint: '06 12 34 56 78',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          // Mot de passe
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Mot de passe *',
                            hint: 'Min. 6 caractères',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.roseGold,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mot de passe requis';
                              }
                              if (value.length < 6) {
                                return 'Minimum 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirmation
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmer le mot de passe *',
                            hint: 'Retapez votre mot de passe',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.roseGold,
                              ),
                              onPressed: () {
                                setState(
                                        () => _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirmation requise';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Bouton d'inscription (style unifié)
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.deepNavy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Text(
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lien vers la connexion (style cohérent)
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
                            Navigator.of(context).pushReplacement(
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
            ),
          ),
        ),
      ),
    );
  }
}
