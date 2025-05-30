import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class AppStyles {
  // Colores principales
  static const Color primaryBrown = Color(0xFF735335);
  static const Color secondaryBrown = Color(0xFFB1835A);
  static const Color lightBrown = Color(0xFFF6F0EA);
  static const Color mediumBrown = Color(0xFFE4D1BF);
  static const Color lightBlue = Color(0xFFAAC4DB);
  static const Color darkGrey = Color(0xFF515151);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  // Tamaños de fuente (aumentados para mejor legibilidad)
  static const double titleFontSize = 32.0;
  static const double subtitleFontSize = 14.0;
  static const double textFontSize = 16.0;
  static const double headingFontSize = 26.0;
  static const double buttonFontSize = 16.0;
  static const double cardTitleFontSize = 18.0;
  static const double cardTextFontSize = 14.0;

  // Estilos de texto
  static TextStyle get appTitle => GoogleFonts.kaushanScript(
    fontSize: titleFontSize,
    color: darkGrey,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get subtitle => GoogleFonts.inter(
    fontSize: subtitleFontSize,
    fontWeight: FontWeight.w200, // Antes era FontWeight.extraLight
    color: darkGrey,
  );

  static TextStyle get bodyText => GoogleFonts.inter(
    fontSize: textFontSize,
    fontWeight: FontWeight.w300, // Antes era FontWeight.light
    color: darkGrey,
  );
  static TextStyle get heading => GoogleFonts.inter(
    fontSize: headingFontSize,
    fontWeight: FontWeight.bold,
    color: darkGrey,
  );

  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: cardTitleFontSize,
    fontWeight: FontWeight.w600,
    color: darkGrey,
  );

  static TextStyle get cardText => GoogleFonts.inter(
    fontSize: cardTextFontSize,
    fontWeight: FontWeight.w400,
    color: darkGrey,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: buttonFontSize,
    fontWeight: FontWeight.w500,
    color: white,
  );

  // Decoraciones de InputField
  static InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      hintStyle: bodyText.copyWith(color: darkGrey.withOpacity(0.5)),
    );
  }
  // Estilos de botones
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryBrown,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: mediumBrown,
    foregroundColor: primaryBrown,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: buttonText.copyWith(color: primaryBrown),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 1,
  );

  // Estilos de tarjetas
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: darkGrey.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get adminCardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: lightBrown, width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryBrown.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  // Tema de la aplicación
  static ThemeData get appTheme => ThemeData(
    primaryColor: primaryBrown,
    scaffoldBackgroundColor: lightBrown,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBrown,
      primary: primaryBrown,
      secondary: secondaryBrown,
      surface: lightBrown,
      background: lightBrown,
      error: Colors.redAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBrown,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: heading.copyWith(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Cambiado a dark para iconos visibles en fondo claro
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBrown,
      ),
    ),
    useMaterial3: true,
  );
}
