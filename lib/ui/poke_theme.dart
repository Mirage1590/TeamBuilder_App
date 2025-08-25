import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PokeColors {
  static const red = Color(0xFFE3350D);      // Poké Ball red
  static const yellow = Color(0xFFFFCB05);   // Pikachu yellow
  static const blue = Color(0xFF3B4CCA);     // Classic blue
  static const dark = Color(0xFF1B1D2A);
  static const lightBg = Color(0xFFFAF6FF);
}

ThemeData buildPokeTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PokeColors.red,
      primary: PokeColors.red,
      tertiary: PokeColors.blue,
      secondary: PokeColors.yellow,
      background: PokeColors.lightBg,
      brightness: Brightness.light,
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.bangers(
        textStyle: base.textTheme.titleLarge?.copyWith(
          letterSpacing: 1.0,
          height: 1.1,
        ),
      ),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.bangers(
        fontSize: 24,
        color: PokeColors.dark,
        letterSpacing: 1.0,
      ),
      iconTheme: const IconThemeData(color: PokeColors.dark),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: PokeColors.yellow.withOpacity(.2),
      selectedColor: PokeColors.red.withOpacity(.15),
      side: const BorderSide(color: PokeColors.blue, width: 1),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Colors.white.withOpacity(.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: PokeColors.blue, width: 2),
      ),
    ),
  );
}
