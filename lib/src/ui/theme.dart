import 'package:flutter/material.dart';

import 'strings.dart';

/// Colours and type for the whole app.
///
/// Two constraints shaped this: the screen has to be readable at a glance on a
/// cheap phone held in a kitchen, and a lot of users will scan by colour and
/// icon rather than by reading. So categories get distinct, saturated colours
/// and text sizes start large.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF00695C);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color surface = Color(0xFFFAF7F2);
  static const Color card = Colors.white;
  static const Color ink = Color(0xFF1B1B1B);
  static const Color inkSoft = Color(0xFF6B6B6B);
  static const Color spend = Color(0xFFC62828);
  static const Color earn = Color(0xFF2E7D32);
  static const Color divider = Color(0xFFE8E2D9);

  /// Set this to a bundled font family to get proper Nastaliq rendering.
  ///
  /// Left null on purpose: Flutter has no Urdu glyphs of its own and falls back
  /// to the device font, which on most Android builds is a Naskh face. That is
  /// legible everywhere with no size cost. Bundling Noto Nastaliq Urdu looks
  /// considerably better but adds roughly a megabyte to an APK that is meant to
  /// stay under eight — a call worth making with real users in front of it, not
  /// before. See README.
  static const String? urduFontFamily = null;

  static ThemeData build(AppLanguage lang) {
    final bool urdu = lang == AppLanguage.urdu;

    // Urdu script sits taller and needs more room between lines than Latin;
    // at 1.2 the descenders of one line collide with the next.
    final double lineHeight = urdu ? 1.7 : 1.35;
    final String? family = urdu ? urduFontFamily : null;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ).copyWith(surface: surface);

    TextStyle base(double size, FontWeight weight, Color color) => TextStyle(
          fontFamily: family,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: lineHeight,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      fontFamily: family,
      dividerColor: divider,
      textTheme: TextTheme(
        displayLarge: base(40, FontWeight.w700, ink),
        headlineMedium: base(26, FontWeight.w700, ink),
        titleLarge: base(20, FontWeight.w600, ink),
        titleMedium: base(17, FontWeight.w600, ink),
        bodyLarge: base(17, FontWeight.w400, ink),
        bodyMedium: base(15, FontWeight.w400, ink),
        bodySmall: base(13, FontWeight.w400, inkSoft),
        labelLarge: base(17, FontWeight.w600, Colors.white),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: base(20, FontWeight.w700, ink),
        iconTheme: const IconThemeData(color: ink),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: divider),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // 56dp tall: this gets tapped quickly, one-handed, sometimes by
          // someone whose hands are wet or busy.
          //
          // Note `Size.fromHeight` is deliberately NOT used here. It expands
          // to `Size(double.infinity, 56)`, an infinite *minimum width*. In a
          // Column that clamps harmlessly to the available width, but in a Row
          // the button demands infinite width and the row overflows. Any
          // button that should span the screen is stretched by its parent
          // instead.
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: base(18, FontWeight.w700, Colors.white),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryDark,
        contentTextStyle: base(15, FontWeight.w500, Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Colour for a category, keyed by its icon.
///
/// Fixed per category rather than generated, so a user learns "green circle =
/// sabzi" and can find it without reading. Colours only repeat across
/// categories that never appear in the same list.
const Map<String, Color> kCategoryColors = <String, Color>{
  'groceries': Color(0xFFE65100),
  'vegetables': Color(0xFF2E7D32),
  'milk': Color(0xFF0277BD),
  'bulb': Color(0xFFF9A825),
  'flame': Color(0xFFD84315),
  'water': Color(0xFF00838F),
  'home': Color(0xFF5D4037),
  'school': Color(0xFF283593),
  'medical': Color(0xFFC2185B),
  'transport': Color(0xFF455A64),
  'mobile': Color(0xFF6A1B9A),
  'staff': Color(0xFF00695C),
  'guests': Color(0xFFAD1457),
  'clothing': Color(0xFF4527A0),
  'charity': Color(0xFF00897B),
  'other': Color(0xFF757575),
  'wallet': Color(0xFF2E7D32),
  'bank': Color(0xFF1565C0),
  'savings': Color(0xFF00838F),
  'salary': Color(0xFF2E7D32),
  'shop': Color(0xFFEF6C00),
  'plus': Color(0xFF546E7A),
  'debt': Color(0xFFC62828),
  'committee': Color(0xFF6D4C41),
  'start': Color(0xFF546E7A),
  'adjust': Color(0xFF757575),
};

Color colorForIcon(String? iconKey) =>
    kCategoryColors[iconKey] ?? AppTheme.inkSoft;
