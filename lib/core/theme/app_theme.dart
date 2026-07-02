import 'package:flutter/material.dart';

class ThemeApp {
  static const Color primaryDark = Color(0xFF10776F);
  static const Color primaryLight = Color(0xFF5CE7D1);
  static const Color buttonColor = Color(0xFF003B63);

  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGrey = Color(0xFF777777);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color softBlue = Color(0xFFD8ECFF);
  static const Color softGreen = Color(0xFFC8DFA4);
  static const Color softBackground = Color(0xFFEAF6F4);

  static const Color locationBlue = Color(0xFF6AB8FF);
  static const Color starColor = Color(0xFFFFB000);

  static const Color successGreen = Color(0xFF0A9B25);
  static const Color pendingOrange = Color(0xFFFF9800);
  static const Color cancelledRed = Color(0xFFE53935);
  static const Color dangerRed = Color(0xFFE53935);

  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color lightGrey = Color(0xFFDADADA);
  static const Color priceDark = Color(0xFF2D3438);

  static const Color adminBackground = Color(0xFFFFFFFF);
  static const Color adminTitle = Color(0xFF080B16);
  static const Color adminSubtitle = Color(0xFF4B3DF4);
  static const Color adminCardBorder = Color(0xFFE4E4E4);

  static const Color adminPurple = Color(0xFF4B3DF4);
  static const Color adminGreen = Color(0xFF2BA84A);
  static const Color adminOrange = Color(0xFFFF8A24);
  static const Color adminBlue = Color(0xFF315BFF);

  static const Color adminSoftPurple = Color(0xFFD8CCFF);
  static const Color adminSoftGreen = Color(0xFFD7F0D8);
  static const Color adminSoftOrange = Color(0xFFFFE3C8);
  static const Color adminSoftBlue = Color(0xFFD5DFFF);

  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [primaryDark, primaryLight],
    ),
  );

  static const BoxDecoration backgroundGradientVertical = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primaryDark, primaryLight],
    ),
  );

  static const BoxDecoration adminWelcomeGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [primaryDark, primaryLight],
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      primaryColor: primaryDark,
      colorScheme: const ColorScheme.light(
        primary: primaryDark,
        secondary: primaryLight,
        surface: white,
        error: dangerRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(color: textDark, size: 28),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textDark,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          height: 1.15,
        ),
        headlineSmall: TextStyle(
          color: textDark,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          color: textDark,
          fontSize: 15.5,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          color: textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          color: textGrey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        hintStyle: const TextStyle(
          color: textGrey,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderGrey, width: 1.3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderGrey, width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: dangerRed, width: 1.3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: dangerRed, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: buttonColor,
        contentTextStyle: const TextStyle(
          color: white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: buttonColor,
        unselectedItemColor: Color(0xFFD8D8D8),
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static BoxShadow softShadow({
    double alpha = 0.08,
    double blurRadius = 14,
    Offset offset = const Offset(0, 7),
  }) {
    return BoxShadow(
      color: black.withValues(alpha: alpha),
      blurRadius: blurRadius,
      offset: offset,
    );
  }

  static BorderRadius radius(double value) {
    return BorderRadius.circular(value);
  }
}
