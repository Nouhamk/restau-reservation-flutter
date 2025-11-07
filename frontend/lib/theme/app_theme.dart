import 'package:flutter/material.dart';

/// Thème lumineux et élégant pour l'application de réservation "Les AL"
class AppTheme {
  // Couleurs principales utilisées
  static const Color lightBackground = Color(0xFFFAF9F7); // Beige très clair
  static const Color lightSurface = Color(0xFFFFFFFF); // Blanc pur
  static const Color darkText = Color(0xFF2C2C2C); // Gris très foncé
  static const Color mediumGrey = Color(0xFF757575); // Gris moyen
  static const Color secondaryGray = Color(0xFF6B6B6B); // Gris secondaire
  static const Color lightGrey = Color(0xFFE8E6E3); // Gris beige clair
  static const Color borderColor = Color(0xFFE5E3DF); // Couleur de bordure beige
  static const Color softBlack = Color(0xFF1A1A1A); // Noir doux
  
  // Couleurs d'accent élégantes
  static const Color roseGold = Color(0xFFB76E79); // Or rosé élégant
  static const Color champagne = Color(0xFFD4A574); // Champagne/or doux
  static const Color deepNavy = Color(0xFF2C3E50); // Bleu nuit profond
  static const Color sageGreen = Color(0xFF87A878); // Vert sauge
  static const Color elegantBurgundy = Color(0xFF8B4049); // Bordeaux élégant
  static const Color warmBeige = Color(0xFFF5F1ED); // Beige chaud

  // Thème lumineux et minimaliste avec touches élégantes
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Palette de couleurs
      colorScheme: ColorScheme.light(
        primary: deepNavy,
        secondary: roseGold,
        surface: lightSurface,
        error: elegantBurgundy,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        tertiary: champagne,
      ),

      // Couleur de fond
      scaffoldBackgroundColor: lightBackground,

      // AppBar
      appBarTheme: AppBarThemeData(
        backgroundColor: lightSurface,
        foregroundColor: deepNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: deepNavy,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: deepNavy),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: roseGold,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepNavy,
          side: BorderSide(color: roseGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Cartes
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightGrey, width: 1),
        ),
      ),

      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: roseGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: elegantBurgundy),
        ),
        labelStyle: TextStyle(color: mediumGrey),
        hintStyle: TextStyle(color: mediumGrey.withOpacity(0.6)),
        prefixIconColor: roseGold,
        suffixIconColor: roseGold,
      ),

      // Typographie
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkText,
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: darkText,
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          color: darkText,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: darkText,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: darkText,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: darkText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: mediumGrey,
          fontSize: 14,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 1,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: softBlack,
        unselectedItemColor: mediumGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // IconTheme
      iconTheme: const IconThemeData(
        color: softBlack,
        size: 24,
      ),
    );
  }

  // Dégradés personnalisés utilisés dans l'application
  
  // Dégradé de fond principal
  static LinearGradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightSurface,
        warmBeige,
        lightBackground,
      ],
    );
  }
  
  // Dégradé élégant or rosé (logo, icônes)
  static LinearGradient get roseGoldGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        roseGold,
        champagne,
        roseGold,
      ],
    );
  }
  
  // Dégradé subtil pour cartes
  static LinearGradient get subtleCardGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        warmBeige.withOpacity(0.3),
      ],
    );
  }

  // Ombres douces pour le thème lumineux
  static List<BoxShadow> get softShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  // Ombres pour cartes
  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
