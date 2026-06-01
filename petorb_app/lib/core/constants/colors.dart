import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBrand = Color(0xFF7B6AD9);
  static const Color secondaryBrand = Color(0xFF9D8BEF);
  static const Color lightLavender = Color(0xFFDCD5F8);
  static const Color bgLavenderWhite = Color(0xFFF5F3FD);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color primaryText = Color(0xFF2E2A4A);
  static const Color secondaryText = Color(0xFF6B6785);
  static const Color hintText = Color(0xFFA5A1BF);
  
  // Alert colors
  static const Color danger = Color(0xFFFF5A79);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);

  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryBrand, secondaryBrand],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgLavenderWhite, white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppStyles {
  // Border Radii
  static const double cardsRadius = 24.0;
  static const double petCardsRadius = 20.0;
  static const double buttonsRadius = 16.0;
  static const double inputsRadius = 14.0;

  static BorderRadius get cardsBorderRadius => BorderRadius.circular(cardsRadius);
  static BorderRadius get petCardsBorderRadius => BorderRadius.circular(petCardsRadius);
  static BorderRadius get buttonsBorderRadius => BorderRadius.circular(buttonsRadius);
  static BorderRadius get inputsBorderRadius => BorderRadius.circular(inputsRadius);

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF7B6AD9).withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    )
  ];
}
