import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import 'about_screen.dart';
import 'help_center_screen.dart';
import 'contact_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _expController = TextEditingController();
  final _rateController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _phoneController.text = user.phone;
      _bioController.text = user.sitterProfile?.bio ?? '';
      _expController.text = user.sitterProfile?.experience ?? '';
      _rateController.text = user.sitterProfile?.rate.toStringAsFixed(0) ?? '0';
    }
  }

  Future<void> _saveProfileChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      await userProvider.updateProfile(
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        experience: _expController.text.trim(),
        rate: double.tryParse(_rateController.text.trim()) ?? 0.0,
      );
      
      setState(() {
        _isEditing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: AppColors.danger),
      );
    }
  }

  Widget _buildProfileInput({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondaryText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? AppColors.bgLavenderWhite : AppColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightLavender.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightLavender.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    if (user == null) return const Center(child: Text('User profile missing.'));

    final isSitter = user.role == 'sitter';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Card Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  boxShadow: AppStyles.softShadow,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryBrand.withOpacity(0.12),
                      backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
                      child: user.photo.isEmpty ? const Icon(Icons.person, size: 36, color: AppColors.primaryBrand) : null,
                    ),
                    const SizedBox(height: 12),
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryText)),
                    Text(user.email, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryBrand.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
                      child: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBrand),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Editing form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Profile Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryText)),
                        TextButton.icon(
                          onPressed: () {
                            if (_isEditing) {
                              _saveProfileChanges();
                            } else {
                              setState(() {
                                _isEditing = true;
                              });
                            }
                          },
                          icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_outlined, size: 16),
                          label: Text(_isEditing ? 'Save' : 'Edit', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildProfileInput(
                      controller: _phoneController,
                      label: 'Emergency Alert Contact',
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    if (isSitter) ...[
                      _buildProfileInput(
                        controller: _expController,
                        label: 'Care Experience Years',
                        enabled: _isEditing,
                      ),
                      _buildProfileInput(
                        controller: _bioController,
                        label: 'Professional Care Bio',
                        enabled: _isEditing,
                      ),
                      _buildProfileInput(
                        controller: _rateController,
                        label: 'Standard Hourly Rate (INR)',
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Support hubs Links Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_center_outlined, color: AppColors.primaryBrand),
                      title: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.support_agent_outlined, color: AppColors.primaryBrand),
                      title: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactSupportScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBrand),
                      title: const Text('About PetOrb Ecosystem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TextButton.icon(
                      onPressed: () async {
                        await userProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out from PetOrb', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
