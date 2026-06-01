import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'logo_widget.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showRoleSelection = false;
  String _selectedRole = 'owner'; // 'owner' or 'sitter'

  final List<Map<String, String>> _slides = [
    {
      'title': 'Manage All Your Pets',
      'description': 'Keep all your pet profiles, health records and feeding schedules in one beautiful place.',
      'icon': '🐶🐱',
    },
    {
      'title': 'Secure Sitter Access',
      'description': 'Generate a unique QR code for your trusted sitter. They get only what they need to know — nothing more.',
      'icon': '🔐',
    },
    {
      'title': 'AI-Powered Pet Care',
      'description': 'Ask PetOrb AI anything about your pet — feeding advice, behavior tips and health guidance.',
      'icon': '🤖',
    }
  ];

  Widget _buildBenefitCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBrand, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.3),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, String title, String subtitle, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgLavenderWhite : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrand : AppColors.lightLavender.withOpacity(0.4),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? AppStyles.softShadow : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : AppColors.bgLavenderWhite,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBrand,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? AppColors.primaryBrand : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBrand : AppColors.lightLavender,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryBrand : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Logo left, Back Arrow right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PetOrbLogo(size: 38, showText: true, isHorizontal: true),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                  onPressed: () {
                    setState(() {
                      _showRoleSelection = false;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            
            // Welcome content
            const Center(
              child: Column(
                children: [
                  Text(
                    'I am a...',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose your role to personalize your experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Role selection cards
            _buildRoleCard(
              'owner',
              'Pet Owner',
              'I want to find the best care for my pets',
              Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              'sitter',
              'Pet Sitter',
              'I want to provide professional pet services',
              Icons.assignment_ind_outlined,
            ),
            const SizedBox(height: 32),

            // Continue Button
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: AppStyles.buttonsBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBrand.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RegisterScreen(initialRole: _selectedRole),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.buttonsBorderRadius,
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Log In link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: AppColors.primaryBrand,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showRoleSelection) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.bgGradient,
          ),
          child: _buildRoleSelectionView(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PetOrbLogo(size: 38, showText: true, isHorizontal: true),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showRoleSelection = true;
                        });
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.primaryBrand,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    final isSlide2 = index == 1;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Premium Card Illustration
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: AppStyles.softShadow,
                              border: Border.all(color: AppColors.lightLavender.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: Text(
                                slide['icon']!,
                                style: const TextStyle(fontSize: 90),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            slide['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Slide 2 specific benefit list cards
                          if (isSlide2) ...[
                            _buildBenefitCard(
                              Icons.access_time,
                              'Time-Limited Access',
                              'Access expires automatically once the booking period ends.',
                            ),
                            _buildBenefitCard(
                              Icons.visibility_off_outlined,
                              'Privacy Guard',
                              'Sensitive info like your last name and home address stay hidden.',
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dot indicators and navigation
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dot indicators
                        Row(
                          children: List.generate(
                            _slides.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.primaryBrand
                                    : AppColors.lightLavender,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // Action Buttons
                        if (_currentPage == _slides.length - 1)
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.mainGradient,
                              borderRadius: AppStyles.buttonsBorderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBrand.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showRoleSelection = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppStyles.buttonsBorderRadius,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                                ],
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBrand,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppStyles.buttonsBorderRadius,
                              ),
                              elevation: 2,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (_currentPage == _slides.length - 1) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          'I already have an account',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
