import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/list_screen.dart';

void main() => runApp(const TaniInventarisApp());

/// Material 3, seed hijau kebun. Display: Bricolage; body: sistem.
/// Tanpa gradien, tanpa ungu, tanpa kartu-menumpuk-kartu.
class TaniInventarisApp extends StatelessWidget {
  const TaniInventarisApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1B7A4D),
    );
    return MaterialApp(
      title: 'Tani Inventaris',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.copyWith(
          displayLarge: GoogleFonts.bricolageGrotesque(
              textStyle: base.textTheme.displayLarge),
          displayMedium: GoogleFonts.bricolageGrotesque(
              textStyle: base.textTheme.displayMedium),
          displaySmall: GoogleFonts.bricolageGrotesque(
              textStyle: base.textTheme.displaySmall),
          headlineMedium: GoogleFonts.bricolageGrotesque(
              textStyle: base.textTheme.headlineMedium),
          titleLarge: GoogleFonts.bricolageGrotesque(
              textStyle: base.textTheme.titleLarge),
        ),
      ),
      home: const ListScreen(),
    );
  }
}
