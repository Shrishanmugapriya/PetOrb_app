import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'logo_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About PetOrb', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: PetOrbLogo(size: 80)),
              const SizedBox(height: 32),
              
              // Project details card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  boxShadow: AppStyles.softShadow,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ecosystem Specifications', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryText)),
                    Divider(height: 20),
                    Text(
                      'PetOrb is an AI-powered pet care ecosystem that seamlessly connects pet owners and professional caregivers. It combines large language model reasoning with strict role security to deliver personalized and context-aware pet sitting guidance.',
                      style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
                    ),
                    SizedBox(height: 16),
                    Text('Core Ecosystem Modules:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 8),
                    Text('• 🐶 Multi-Pet Profiles: Details diet, meds, & vet contacts.', style: TextStyle(fontSize: 12, height: 1.3)),
                    Text('• 🤖 AI Care Assistant: Context-aware Gemini model prompt reasoning.', style: TextStyle(fontSize: 12, height: 1.3)),
                    Text('• 💼 Marketplace: Open bidding for jobs with hiring status controls.', style: TextStyle(fontSize: 12, height: 1.3)),
                    Text('• 🔐 Access Security: Revocable, temporary check-in QR codes.', style: TextStyle(fontSize: 12, height: 1.3)),
                    Text('• ⚠️ Lost Recovery: Public web panels accessible without log-in.', style: TextStyle(fontSize: 12, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Developer card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Version', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                    Text('v1.0.0 (Production Release)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
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
