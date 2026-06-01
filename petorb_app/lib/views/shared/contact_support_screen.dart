import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _msgController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendTicket() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Simulated support ticket submission delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support ticket sent! We will respond shortly.'), backgroundColor: AppColors.success),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText)),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.support_agent_rounded, size: 48, color: AppColors.primaryBrand),
                    const SizedBox(height: 10),
                    const Text('Need assistance with PetOrb?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text(
                      'Our technical team is online. Send us details of billing issues, scanner verify errors, or account profile queries.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 12, height: 1.4),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Icon(Icons.email, color: AppColors.primaryBrand),
                          const SizedBox(height: 4),
                          const Text('Email Support', style: TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.bold)),
                          Text('support@petorb.com', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBrand.withOpacity(0.8))),
                        ]),
                        Column(children: [
                          const Icon(Icons.phone, color: AppColors.primaryBrand),
                          const SizedBox(height: 4),
                          const Text('Helpline Phone', style: TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.bold)),
                          Text('+1 (800) 123-4567', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBrand.withOpacity(0.8))),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Open Support Ticket', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryText)),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _msgController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your message details here...',
                  hintStyle: const TextStyle(color: AppColors.hintText),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightLavender), borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryBrand), borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),

              _isSending
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.mainGradient,
                        borderRadius: AppStyles.buttonsBorderRadius,
                      ),
                      child: ElevatedButton(
                        onPressed: _sendTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: AppStyles.buttonsBorderRadius),
                        ),
                        child: const Text('Submit Support Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
