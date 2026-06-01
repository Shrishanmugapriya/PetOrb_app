import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/colors.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';

import 'providers/user_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/job_provider.dart';
import 'providers/chat_provider.dart';

import 'views/shared/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HTTP Client API & local shared preference stores
  await ApiService.init();
  
  // Initialize Firebase authentication wrapper (falls back gracefully to JWT on simulator bypass)
  await AuthService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const PetOrbApp(),
    ),
  );
}

class PetOrbApp extends StatelessWidget {
  const PetOrbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetOrb Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBrand,
          primary: AppColors.primaryBrand,
          secondary: AppColors.secondaryBrand,
          background: AppColors.bgLavenderWhite,
          surface: Colors.white,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.bgLavenderWhite,
        fontFamily: 'Outfit',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryText),
          titleTextStyle: TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButtonThemeFrom(
            backgroundColor: AppColors.primaryBrand,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBrand,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Outfit'),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }

  // Simple Helper for ThemeData properties
  static ButtonStyle ElevatedButtonThemeFrom({
    required Color backgroundColor,
    required Color foregroundColor,
    required TextStyle textStyle,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: textStyle,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
