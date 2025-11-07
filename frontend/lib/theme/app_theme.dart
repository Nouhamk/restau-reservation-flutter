import 'package:flutter/material.dart';

/// Thème inspiré du style pub anglais "Au Bureau"
/// Couleurs sombres, chaleureuses et élégantes
class AppTheme {
  // Couleurs principales - Style pub anglais
  static const Color primaryDark = Color(0xFF1A1A1A); // Noir profond
  static const Color secondaryBrown = Color(0xFF8B4513); // Marron cuir
  static const Color accentGold = Color(0xFFD4AF37); // Or/laiton
  static const Color backgroundDark = Color(0xFF2C2C2C); // Gris foncé
  static const Color backgroundLight = Color(0xFFF5F5F5); // Blanc cassé

  // Couleurs complémentaires
  static const Color leatherBrown = Color(0xFF6B4423); // Cuir marron foncé
  static const Color woodBrown = Color(0xFF4A3728); // Bois sombre
  static const Color warmRed = Color(0xFF8B0000); // Rouge chaleureux
  static const Color deepGreen = Color(0xFF2F4F2F); // Vert anglais
  static const Color creamWhite = Color(0xFFFFF8DC); // Crème

  // Thème principal de l'application
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Palette de couleurs
      colorScheme: ColorScheme.dark(
        primary: accentGold,
        secondary: secondaryBrown,
        surface: backgroundDark,
        error: warmRed,
        onPrimary: primaryDark,
        onSecondary: Colors.white,
        onSurface: creamWhite,
      ),

      // Couleur de fond
      scaffoldBackgroundColor: primaryDark,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: accentGold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: accentGold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: accentGold),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGold,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Cartes
      cardTheme: CardThemeData(
        color: backgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accentGold.withOpacity(0.2), width: 1),
        ),
      ),

      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentGold.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentGold.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: warmRed),
        ),
        labelStyle: TextStyle(color: creamWhite.withOpacity(0.7)),
        hintStyle: TextStyle(color: creamWhite.withOpacity(0.5)),
        prefixIconColor: accentGold,
        suffixIconColor: accentGold,
      ),

      // Typographie
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: accentGold,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          color: accentGold,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        displaySmall: TextStyle(
          color: creamWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: accentGold,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: creamWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: creamWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: creamWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: creamWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: creamWhite,
          fontSize: 14,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: accentGold.withOpacity(0.2),
        thickness: 1,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryDark,
        selectedItemColor: accentGold,
        unselectedItemColor: creamWhite.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // IconTheme
      iconTheme: const IconThemeData(
        color: accentGold,
        size: 24,
      ),
    );
  }

  // Dégradés personnalisés
  static LinearGradient get primaryGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryDark,
        backgroundDark,
        primaryDark,
      ],
    );
  }

  static LinearGradient get goldGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFD4AF37),
        Color(0xFFF4E5B2),
        Color(0xFFD4AF37),
      ],
    );
  }

  // BoxShadow pour effet relief cuir
  static List<BoxShadow> get leatherShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: accentGold.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
}