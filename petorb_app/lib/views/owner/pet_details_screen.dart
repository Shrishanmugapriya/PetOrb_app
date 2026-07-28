import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import 'add_edit_pet_screen.dart';

class PetDetailsScreen extends StatelessWidget {
  final PetModel pet;

  const PetDetailsScreen({super.key, required this.pet});

  void _showLostPetQR(BuildContext context) {
    // Generate public url for lost pet page
    final publicUrl = '${ApiService.baseUrl}/qr/lost-pet/${pet.id}';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: AppStyles.cardsBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🚨 Lost Pet Recovery QR',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'If your pet is lost, anyone scanning this QR code will see your phone number and instructions without needing to log in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.3),
                ),
                const SizedBox(height: 24),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgLavenderWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightLavender),
                  ),
                  child: QrImageView(
                    data: publicUrl,
                    version: QrVersions.auto,
                    size: 200.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primaryBrand,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: AppColors.secondaryBrand,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  pet.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryText, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Print this QR and attach it to your pet\'s collar.',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
    final petProvider = Provider.of<PetProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
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
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primaryText, size: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AddEditPetScreen(pet: pet)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Pet Profile?'),
                        content: Text('Are you sure you want to remove ${pet.name}? This cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await petProvider.deletePet(pet.id);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
            ],
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
                      ElevatedButton.icon(
                        onPressed: () => _showLostPetQR(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.qr_code, size: 18),
                        label: const Text('Lost QR', style: TextStyle(fontWeight: FontWeight.bold)),
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

                  // Section: Medical Info
                  _buildSectionCard(
                    title: 'Medical Summary',
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
                      const Text('Primary Veterinarian:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(
                        pet.vetInfo.name.isNotEmpty 
                            ? '${pet.vetInfo.name} (${pet.vetInfo.phone})\nAddress: ${pet.vetInfo.address}' 
                            : 'No clinic info added',
                        style: const TextStyle(color: AppColors.secondaryText, height: 1.3),
                      ),
                    ],
                  ),

                  // Section: Care & Feeding
                  _buildSectionCard(
                    title: 'Daily Care Routine',
                    icon: Icons.restaurant_menu_outlined,
                    children: [
                      const Text('Feeding Schedule:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 6),
                      if (pet.feedingSchedule.isEmpty)
                        const Text('No feeding times added.', style: TextStyle(color: AppColors.secondaryText))
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
                      const Text('Behavioral Characteristics:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(
                        pet.behaviourNotes.isNotEmpty 
                            ? pet.behaviourNotes 
                            : (pet.specialInstructions.isNotEmpty ? pet.specialInstructions : 'None'), 
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),

                  // Section: Emergency Logs
                  _buildSectionCard(
                    title: 'Emergency Details',
                    icon: Icons.emergency_share_outlined,
                    children: [
                      const Text('Recovery Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text(
                        pet.specialInstructions.isEmpty ? 'No special instructions recorded.' : pet.specialInstructions,
                        style: const TextStyle(color: AppColors.secondaryText, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      const Text('Emergency Contacts:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 6),
                      if (pet.emergencyContacts.isEmpty)
                        const Text('None added.', style: TextStyle(color: AppColors.secondaryText))
                      else
                        ...pet.emergencyContacts.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${c.name} (${c.relationship})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(c.phone, style: const TextStyle(color: AppColors.primaryBrand, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
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
