import 'package:flutter/material.dart';

// Palette DoktaNet : vert émeraude (santé), menthe (vitalité), or (chaleur togolaise).
const cDark = Color(0xFF0B3D2E);
const cMid = Color(0xFF16805A);
const cMint = Color(0xFF3DDC97);
const cTeal = Color(0xFF0E9AA7);
const cAccent = Color(0xFFF5A623);
const cBg = Color(0xFFF2F8F5);
const cInk = Color(0xFF12221B);
const cMuted = Color(0xFF5B6E65);

const kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0B3D2E), Color(0xFF16805A)],
);
const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF16805A), Color(0xFF0E9AA7)],
);
const kGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF5A623), Color(0xFFFFC857)],
);
const kHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF062B20), Color(0xFF0B3D2E), Color(0xFF16805A)],
);

ThemeData buildTheme() {
  final radius14 = BorderRadius.circular(14);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: cMid, primary: cMid, secondary: cAccent),
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
      indicatorColor: cMid.withOpacity(0.16),
      height: 68,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      side: BorderSide(color: cMid.withOpacity(0.35)),
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
        side: BorderSide(color: cMid.withOpacity(0.55), width: 1.4),
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
      border: OutlineInputBorder(borderRadius: radius14, borderSide: BorderSide(color: cDark.withOpacity(0.12))),
      enabledBorder: OutlineInputBorder(borderRadius: radius14, borderSide: BorderSide(color: cDark.withOpacity(0.12))),
      focusedBorder: OutlineInputBorder(borderRadius: radius14, borderSide: const BorderSide(color: cMid, width: 2)),
    ),
  );
}
