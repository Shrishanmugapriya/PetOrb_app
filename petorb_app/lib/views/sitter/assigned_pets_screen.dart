import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/pet_model.dart';
import 'ai_assistant_screen.dart';

class AssignedPetDetailsScreen extends StatelessWidget {
  final PetModel pet;

  const AssignedPetDetailsScreen({super.key, required this.pet});

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppStyles.cardsBorderRadius,
        boxShadow: AppStyles.softShadow,
        border: Border.all(color: AppColors.lightLavender.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBrand, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryText),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgLavenderWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image Header (No edit or delete buttons for sitters)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primaryBrand,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: pet.photo.isNotEmpty
                  ? Image.network(pet.photo, fit: BoxFit.cover, errorBuilder: (c, o, s) => Container(color: AppColors.lightLavender))
                  : Container(
                      color: AppColors.lightLavender,
                      child: const Center(child: Icon(Icons.pets, size: 80, color: AppColors.primaryBrand)),
                    ),
            ),
          ),

          // Details List
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgGradient,
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pet Name & Species
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${pet.species} • ${pet.breed}',
                            style: const TextStyle(fontSize: 15, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_open, color: AppColors.success, size: 14),
                            SizedBox(width: 4),
                            Text('Access Active', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricBadge('AGE', '${pet.age} Yrs', '📅'),
                      _buildMetricBadge('GENDER', pet.gender, '🧬'),
                      _buildMetricBadge('WEIGHT', '${pet.weight} kg', '⚖️'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // AI Consultation Shortcut Button for Sitters
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: AppColors.mainGradient,
                      borderRadius: AppStyles.cardsBorderRadius,
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryBrand.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SitterAiAssistantScreen(pet: pet)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: AppStyles.cardsBorderRadius),
                      ),
                      icon: const Icon(Icons.support_agent, color: Colors.white),
                      label: Text(
                        'Chat with AI Assistant about ${pet.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),

                  // Section: Medical Info (Read-only)
                  _buildSectionCard(
                    title: 'Medical Reference',
                    icon: Icons.medical_services_outlined,
                    children: [
                      const Text('Allergies & Restrictions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(
                        pet.allergies.isEmpty ? 'None recorded' : pet.allergies.join(', '),
                        style: TextStyle(color: pet.allergies.isEmpty ? AppColors.secondaryText : AppColors.danger, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text('Current Medications:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      if (pet.currentMedications.isEmpty)
                        const Text('None', style: TextStyle(color: AppColors.secondaryText))
                      else
                        ...pet.currentMedications.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text('• ${m.name} (${m.dosage}) - ${m.frequency}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            )),
                      const SizedBox(height: 16),
                      const Text('Veterinary Contact:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(
                        pet.vetInfo.name.isNotEmpty 
                            ? '${pet.vetInfo.name} (${pet.vetInfo.phone})\nAddress: ${pet.vetInfo.address}' 
                            : 'No clinic info added',
                        style: const TextStyle(color: AppColors.secondaryText, height: 1.3),
                      ),
                    ],
                  ),

                  // Section: Care & Feeding (Read-only)
                  _buildSectionCard(
                    title: 'Care & Food Instructions',
                    icon: Icons.restaurant_menu_outlined,
                    children: [
                      const Text('Feeding Routine:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 6),
                      if (pet.feedingSchedule.isEmpty)
                        const Text('No feeding times scheduled.', style: TextStyle(color: AppColors.secondaryText))
                      else
                        ...pet.feedingSchedule.map((f) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.bgLavenderWhite, borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(f.time, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBrand)),
                                  Text('${f.foodType} (${f.amount})', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                                ],
                              ),
                            )),
                      const SizedBox(height: 16),
                      const Text('Food Preferences:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(pet.foodPreferences.isEmpty ? 'None' : pet.foodPreferences.join(', '), style: const TextStyle(color: AppColors.secondaryText)),
                      const SizedBox(height: 16),
                      const Text('Sleep Schedule:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(pet.sleepSchedule.isEmpty ? 'Not specified' : pet.sleepSchedule, style: const TextStyle(color: AppColors.secondaryText)),
                      const SizedBox(height: 16),
                      const Text('Activity Routine:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(pet.activityRoutine.isEmpty ? 'Not specified' : pet.activityRoutine, style: const TextStyle(color: AppColors.secondaryText)),
                      const SizedBox(height: 16),
                      const Text('Behavioral Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(pet.behaviourNotes.isEmpty ? 'None' : pet.behaviourNotes, style: const TextStyle(color: AppColors.secondaryText)),
                    ],
                  ),

                  // Section: Emergency Logs (Read-only)
                  _buildSectionCard(
                    title: 'Special / Emergency Instructions',
                    icon: Icons.emergency_share_outlined,
                    children: [
                      const Text('Care Guidelines:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(
                        pet.specialInstructions.isEmpty ? 'No special instructions recorded.' : pet.specialInstructions,
                        style: const TextStyle(color: AppColors.secondaryText, height: 1.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
