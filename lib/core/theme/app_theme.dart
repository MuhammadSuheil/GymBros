import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../constants/app_colors.dart'; 

class AppTheme {
  
  static ThemeData get darkTheme {
    return ThemeData(
      
      primarySwatch: _createMaterialColor(AppColors.secondary), 
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.onError,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background, 
        foregroundColor: AppColors.textPrimary, 
        titleTextStyle: GoogleFonts.outfit( 
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, 
          foregroundColor: AppColors.onPrimary, 
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)), 
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
         style: OutlinedButton.styleFrom(
           foregroundColor: AppColors.onPrimary, 
           side: const BorderSide(color: AppColors.primary),
           padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
           textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
         )
      ),
       textButtonTheme: TextButtonThemeData(
         style: TextButton.styleFrom(
           foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
         )
       ),

      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide.none, 
        ),
        enabledBorder: OutlineInputBorder( 
           borderRadius: BorderRadius.circular(32.0),
           borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder( 
           borderRadius: BorderRadius.circular(32.0),
           borderSide: const BorderSide(color: Colors.transparent),
        ),
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
      ),

      
      cardTheme: CardTheme(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0), 
      ),

      
       bottomNavigationBarTheme: BottomNavigationBarThemeData(
         backgroundColor: AppColors.surface,
         selectedItemColor: AppColors.primary,
         unselectedItemColor: AppColors.divider,
         selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
         unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
         type: BottomNavigationBarType.fixed,
         elevation: 8.0,
       ),

      
      textTheme: GoogleFonts.outfitTextTheme( 
        ThemeData.light().textTheme.copyWith( 
            
            
            
            
         ),
      ),
      
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  
  
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  
  
}
