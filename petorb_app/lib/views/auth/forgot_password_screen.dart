import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/auth_service.dart';
import '../shared/logo_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.sendPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset instructions sent to your email.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                    const Center(child: PetOrbLogo(size: 60)),
                    const SizedBox(height: 32),
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
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your email address below and we will send you instructions to reset your password.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                              height: 1.4,
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
                          const SizedBox(height: 24),

                          // Submit Button
                          _isLoading
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
                                    onPressed: _handleReset,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppStyles.buttonsBorderRadius,
                                      ),
                                    ),
                                    child: const Text(
                                      'Send Reset Link',
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
