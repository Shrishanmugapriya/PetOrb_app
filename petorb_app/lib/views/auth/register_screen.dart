import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/pet_provider.dart';
import '../shared/logo_widget.dart';
import 'login_screen.dart';
import '../owner/dashboard_screen.dart' as owner;
import '../sitter/dashboard_screen.dart' as sitter;

class RegisterScreen extends StatefulWidget {
  final String initialRole;
  const RegisterScreen({super.key, this.initialRole = 'owner'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'owner';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    try {
      await userProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      // Pre-fetch pets
      await petProvider.fetchPets();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to PetOrb, ${userProvider.currentUser!.name}!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Route based on role
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
      
      String message = e.toString().replaceAll("Exception: ", "");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildRoleCard(String role, String title, String subtitle, String icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgLavenderWhite : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrand : AppColors.lightLavender.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppStyles.softShadow : [],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isSelected ? AppColors.primaryBrand : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryBrand,
                size: 22,
              ),
          ],
        ),
      ),
    );
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
                    const Center(child: PetOrbLogo(size: 60, showText: true, isHorizontal: true)),
                    const SizedBox(height: 24),
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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Role Picker Cards
                          const Text(
                            'Select Account Type',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          _buildRoleCard(
                            'owner',
                            'Pet Owner',
                            'I want to manage my pets, post sitting jobs, and consult AI.',
                            '🐶',
                          ),
                          const SizedBox(height: 10),
                          _buildRoleCard(
                            'sitter',
                            'Pet Sitter',
                            'I want to offer sitting services, scan access keys, and review care schedules.',
                            '🙋‍♂️',
                          ),
                          const SizedBox(height: 20),

                          // Name Field
                          const Text(
                            'Full Name',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'e.g. Shrish',
                              hintStyle: const TextStyle(color: AppColors.hintText),
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.secondaryText),
                              filled: true,
                              fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              if (val == null || val.trim().isEmpty) return 'Full name is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

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
                              hintText: 'e.g. owner@petorb.com',
                              hintStyle: const TextStyle(color: AppColors.hintText),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondaryText),
                              filled: true,
                              fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          const SizedBox(height: 16),

                          // Phone Field
                          const Text(
                            'Phone Number',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'e.g. +91 98765 43210',
                              hintStyle: const TextStyle(color: AppColors.hintText),
                              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.secondaryText),
                              filled: true,
                              fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              if (val == null || val.trim().isEmpty) return 'Phone number is required for emergency alerts';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                    onPressed: _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppStyles.buttonsBorderRadius,
                                      ),
                                    ),
                                    child: const Text(
                                      'Register',
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Sign In',
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
