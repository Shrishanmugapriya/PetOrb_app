import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/pet_provider.dart';
import 'logo_widget.dart';
import 'onboarding_screens.dart';
import '../auth/login_screen.dart';
import '../owner/dashboard_screen.dart' as owner;
import '../sitter/dashboard_screen.dart' as sitter;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Hold splash for 2.5 seconds to show brand logo animations
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    // Check user session
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.checkSession();

    if (!mounted) return;

    if (userProvider.isAuthenticated) {
      // Pre-fetch pets for the dashboard
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      await petProvider.fetchPets();
      
      if (!mounted) return;

      // Navigate according to User Role
      if (userProvider.currentUser!.role == 'owner') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const owner.OwnerDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const sitter.SitterDashboardScreen()),
        );
      }
    } else {
      // First time onboarding check, fallback to Onboarding Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreens()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PetOrbLogo(size: 110)
                  .animate()
                  .fade(duration: 800.ms)
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .then()
                  .shimmer(duration: 1200.ms, delay: 300.ms),
              const SizedBox(height: 40),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrand),
                ),
              ).animate().fade(delay: 600.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
