import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.lightLavender.withOpacity(0.4)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryText),
        ),
        iconColor: AppColors.primaryBrand,
        textColor: AppColors.primaryBrand,
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText)),
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
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'How does the AI Pet Assistant work?',
              'When you query the chatbot, the system extracts your pet\'s registered details, medical record logs, vaccination calendar, feeding portion settings, and allergies. It compiles this data into a structured prompt context and requests responses from the Transformer-Based Large Language Model (Google Gemini API). This ensures care advice is 100% custom-tailored rather than generic.',
            ),
            _buildFaqItem(
              'How do sitters get access keys?',
              'Once you hire a caregiver for a posted sitting job, the backend server automatically generates temporary, revocable security tokens. These keys are linked to the sitter\'s account and expire when the job ends. The sitter scans your screen QR to verify permissions and unlock care profile details.',
            ),
            _buildFaqItem(
              'How does the public Lost Pet Recovery tag work?',
              'On your pet profile details sheet, tapping the "Lost QR" button generates a QR code pointing to a public web page on our backend server. No app login is required to open this page. Anyone scanning it can view the pet photo, breed, age, special recovery guidelines, and tap to call you immediately.',
            ),
            _buildFaqItem(
              'Are sitter accounts verified?',
              'Yes, sitters must set up their experience bio and rate fields. Owners can review reviews and credentials before accepting sitter applications.',
            ),
          ],
        ),
      ),
    );
  }
}
