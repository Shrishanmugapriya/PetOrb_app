import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/pet_provider.dart';
import '../shared/logo_widget.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../owner/dashboard_screen.dart' as owner;
import '../sitter/dashboard_screen.dart' as sitter;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    try {
      await userProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Pre-fetch pets for the dashboards
      await petProvider.fetchPets();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${userProvider.currentUser!.name}!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate based on user role
      if (userProvider.currentUser!.role == 'owner') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const owner.OwnerDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const sitter.SitterDashboardScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      // Extract error message
      String message = e.toString().replaceAll("Exception: ", "");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: PetOrbLogo(size: 80)),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppStyles.cardsBorderRadius,
                        boxShadow: AppStyles.softShadow,
                        border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your email and password to access your pets or sitter account.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Email Field
                          const Text(
                            'Email Address',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'e.g. bruno@petorb.com',
                              hintStyle: const TextStyle(color: AppColors.hintText),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondaryText),
                              filled: true,
                              fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: AppStyles.inputsBorderRadius,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: AppStyles.inputsBorderRadius,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Email is required';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBrand,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(color: AppColors.hintText),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.secondaryText),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.secondaryText,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: AppStyles.inputsBorderRadius,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: AppStyles.inputsBorderRadius,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Password is required';
                              if (val.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Submit Button
                          userProvider.isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(color: AppColors.primaryBrand),
                                  ),
                                )
                              : Container(
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
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppStyles.buttonsBorderRadius,
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primaryBrand,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
