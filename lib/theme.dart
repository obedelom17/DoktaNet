import 'package:flutter/material.dart';

// Palette DoktaNet : bleu du logo #0E5976 (confiance), cyan (clarté), corail (chaleur). Distincte de FiscAI (vert/or).
const cDark = Color(0xFF0A3B50);
const cMid = Color(0xFF0E5976);
const cMint = Color(0xFF5CC8E0);
const cTeal = Color(0xFF1A8FB5);
const cOk = Color(0xFF1E9E6A); // succès (statuts terminé / payé)
const cAccent = Color(0xFFFF6F59);
const cBg = Color(0xFFF1F6F9);
const cInk = Color(0xFF0F2230);
const cMuted = Color(0xFF5A6E7C);

const kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0A3B50), Color(0xFF0E5976)],
);
const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0E5976), Color(0xFF1A8FB5)],
);
const kGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6F59), Color(0xFFFF9E7A)],
);
const kHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF062B3C), Color(0xFF0A3B50), Color(0xFF0E5976)],
);

ThemeData buildTheme() {
  final radius14 = BorderRadius.circular(14);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: cMid, primary: cMid, secondary: cAccent),
    scaffoldBackgroundColor: cBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: cDark,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 15.5, color: cInk),
      bodyLarge: TextStyle(fontSize: 17, color: cInk),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: cMid),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cDark,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: radius14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: cMid.withValues(alpha: 0.16),
      height: 68,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      side: BorderSide(color: cMid.withValues(alpha: 0.35)),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(color: cDark, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cMid,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: radius14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cDark,
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        side: BorderSide(color: cMid.withValues(alpha: 0.55), width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: radius14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cMid,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: radius14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: radius14,
          borderSide: BorderSide(color: cDark.withValues(alpha: 0.12))),
      enabledBorder: OutlineInputBorder(
          borderRadius: radius14,
          borderSide: BorderSide(color: cDark.withValues(alpha: 0.12))),
      focusedBorder: OutlineInputBorder(
          borderRadius: radius14,
          borderSide: const BorderSide(color: cMid, width: 2)),
    ),
  );
}
