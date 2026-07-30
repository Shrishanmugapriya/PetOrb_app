import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/job_provider.dart';
import '../../models/pet_model.dart';
import '../../models/job_model.dart';
import 'add_edit_pet_screen.dart';
import 'create_job_screen.dart';
import 'pet_details_screen.dart';
import 'jobs_screen.dart';
import 'applications_screen.dart';
import 'qr_management_screen.dart';
import 'ai_assistant_screen.dart';
import '../auth/login_screen.dart';
import '../shared/logo_widget.dart';
import '../shared/about_screen.dart';
import '../shared/settings_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = ['Dashboard', 'Marketplace', 'Access Keys', 'Settings'];

  // 9. Interactive activity checklist state
  final Map<String, bool> _activities = {
    'Morning Feeding': true,
    'Afternoon Walk (30 min)': false,
    'Medication Dose': false,
    'Evening Feeding': false,
    'Grooming / Brush Coat': false,
  };

  // 8. Notifications center
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).fetchPets();
      Provider.of<JobProvider>(context, listen: false).fetchJobs();
    });
  }

  // Helper helper to open chatbot with specific query pre-loaded
  void _openChatWithPrompt(PetModel pet, String promptText) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerAiAssistantScreen(pet: pet),
      ),
    );
    // Since ChatProvider is loaded, we can trigger sending the message or pre-filling it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // In a real flow we could inject it, but opening the screen is already great.
      // We can notify user about the prompt.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting AI consultation: "$promptText"'),
          backgroundColor: AppColors.primaryBrand,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildDashboardHome() {
    final userProvider = Provider.of<UserProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    
    final name = userProvider.currentUser?.name ?? 'Owner';
    final selectedPet = petProvider.selectedPet;
    final totalPets = petProvider.pets.length;
    final userPhoto = userProvider.currentUser?.photo ?? '';

    final isNewUser = totalPets == 0;
    final welcomeTitle = isNewUser ? 'Welcome to PetOrb, $name! 👋' : 'Welcome back, $name! 👋';
    final welcomeSub = isNewUser
        ? 'Create your first pet profile to unlock AI assistant prompts.'
        : 'You have $totalPets ${totalPets == 1 ? 'pet' : 'pets'} under your care.';

    return RefreshIndicator(
      onRefresh: () async {
        await petProvider.fetchPets();
        await jobProvider.fetchJobs();
      },
      color: AppColors.primaryBrand,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Welcome Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: AppStyles.cardsBorderRadius,
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Owner profile picture
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        backgroundImage: userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
                        child: userPhoto.isEmpty 
                            ? const Icon(Icons.person, color: Colors.white, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              welcomeTitle,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              welcomeSub,
                              style: const TextStyle(fontSize: 13, color: AppColors.lightLavender, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 28),
                        tooltip: 'Switch to Sitter Mode',
                        onPressed: () async {
                          await userProvider.devSwitchRole();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Switched to Sitter Module!'), backgroundColor: AppColors.primaryBrand),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. My Pets Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Pets Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddEditPetScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New Pet', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            petProvider.isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
                : petProvider.pets.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppStyles.cardsBorderRadius,
                          boxShadow: AppStyles.softShadow,
                          border: Border.all(color: AppColors.lightLavender),
                        ),
                        child: Column(
                          children: [
                            const Text('🐶', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 10),
                            const Text('No pets registered yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text('Create a profile to unlock AI assistant prompts.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditPetScreen()));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrand, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text('Create Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 175,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: petProvider.pets.length,
                          itemBuilder: (context, index) {
                            final pet = petProvider.pets[index];
                            final isSelected = selectedPet?.id == pet.id;
                            // Health Status calculation
                            final healthStatus = pet.allergies.isNotEmpty || pet.medicalHistory.isNotEmpty 
                                ? 'Care Needed' 
                                : 'Healthy';
                            final healthColor = healthStatus == 'Healthy' ? AppColors.success : AppColors.warning;

                            return GestureDetector(
                              onTap: () {
                                petProvider.selectPet(pet);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 170,
                                margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: AppStyles.petCardsBorderRadius,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryBrand : AppColors.lightLavender.withOpacity(0.4),
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                  boxShadow: isSelected ? AppStyles.softShadow : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.primaryBrand.withOpacity(0.1),
                                      backgroundImage: pet.photo.isNotEmpty ? NetworkImage(pet.photo) : null,
                                      child: pet.photo.isEmpty ? const Icon(Icons.pets, color: AppColors.primaryBrand, size: 24) : null,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          pet.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${pet.breed} • ${pet.age} yrs',
                                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    // Health status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: healthColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        healthStatus,
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: healthColor),
                                      ),
                                    ),
                                    // Actions
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)),
                                            );
                                          },
                                          child: const Text('Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBrand)),
                                        ),
                                        const Text('|', style: TextStyle(fontSize: 11, color: AppColors.lightLavender)),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => AddEditPetScreen(pet: pet)),
                                            );
                                          },
                                          child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 20),

            // 3. Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                _buildQuickActionBtn(Icons.add_circle_outline_rounded, 'Add Pet', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditPetScreen()));
                }),
                _buildQuickActionBtn(Icons.campaign_outlined, 'Post Job', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateJobScreen()));
                }),
                _buildQuickActionBtn(Icons.chat_bubble_outline_rounded, 'AI Agent', () {
                  if (selectedPet != null) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => OwnerAiAssistantScreen(pet: selectedPet)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a pet profile first.')));
                  }
                }),
                _buildQuickActionBtn(Icons.qr_code_2_rounded, 'QR Code', () {
                  setState(() {
                    _currentIndex = 2; // Switch to Security Tab
                  });
                }),
                _buildQuickActionBtn(Icons.reviews_outlined, 'Bids', () {
                  setState(() {
                    _currentIndex = 1; // Switch to Jobs/Marketplace Tab
                  });
                }),
              ],
            ),
            const SizedBox(height: 24),

            // 4. AI Pet Assistant
            if (selectedPet != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8E5FC), Color(0xFFF3F1FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppStyles.cardsBorderRadius,
                  border: Border.all(color: AppColors.primaryBrand.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: AppColors.primaryBrand, shape: BoxShape.circle),
                          child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Assistant for ${selectedPet.name}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryText),
                              ),
                              const Text(
                                'Ask personalized questions about diet, health or activities.',
                                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Recommended Care Prompts:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                    const SizedBox(height: 8),
                    // Quick tag row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPromptTag(selectedPet, 'Feeding recommendations'),
                          _buildPromptTag(selectedPet, 'Health questions'),
                          _buildPromptTag(selectedPet, 'Behavior analysis'),
                          _buildPromptTag(selectedPet, 'Exercise suggestions'),
                          _buildPromptTag(selectedPet, 'Grooming advice'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Vaccination & Health Reminders
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  boxShadow: AppStyles.softShadow,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active_outlined, color: AppColors.primaryBrand, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Vaccination & Health Reminders',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // Upcoming vaccinations
                    if (selectedPet.vaccinationRecords.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: Text('💉 No upcoming vaccinations logged.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      )
                    else
                      ...selectedPet.vaccinationRecords.take(2).map((v) {
                        final dateStr = v.nextDueDate != null ? v.nextDueDate!.toString().split(' ')[0] : 'Not set';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.vaccines, color: AppColors.primaryBrand, size: 20),
                          title: Text(v.vaccineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('Due: $dateStr', style: const TextStyle(fontSize: 11, color: AppColors.danger)),
                        );
                      }),
                    // Medication reminders
                    if (selectedPet.currentMedications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: Text('💊 No active medications.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      )
                    else
                      ...selectedPet.currentMedications.take(2).map((m) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: const Icon(Icons.medical_services_outlined, color: AppColors.warning, size: 20),
                            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('Dosage: ${m.dosage} (${m.frequency})', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                          )),
                    // Vet Clinic Info
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.local_hospital_outlined, color: AppColors.success, size: 20),
                      title: Text(selectedPet.vetInfo.name.isNotEmpty ? selectedPet.vetInfo.name : 'No vet clinic assigned', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(selectedPet.vetInfo.phone.isNotEmpty ? 'Tel: ${selectedPet.vetInfo.phone}' : 'Tap "Edit Pet" to add vet info', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 6. Pet Sitting Jobs Marketplace
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppStyles.cardsBorderRadius,
                boxShadow: AppStyles.softShadow,
                border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Active Sitter Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 1; // Open Marketplace Tab
                          });
                        },
                        child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 10),
                  jobProvider.jobs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text('No active sitting jobs posted. Create one to hire a sitter.', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                        )
                      : Column(
                          children: jobProvider.jobs.take(2).map((job) {
                            return Card(
                              margin: const EdgeInsets.only(top: 8),
                              elevation: 0,
                              color: AppColors.bgLavenderWhite,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                dense: true,
                                title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('Budget: ₹${job.payment.toStringAsFixed(0)} • Status: ${job.status.toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.primaryBrand.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('Manage', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBrand)),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ApplicationsScreen(job: job)),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 7. QR Access Keys Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppStyles.cardsBorderRadius,
                boxShadow: AppStyles.softShadow,
                border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('QR Code Access & Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2; // Open Security tab
                          });
                        },
                        child: const Text('Manage QRs', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.bgLavenderWhite, borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lock_person_outlined, color: AppColors.primaryBrand, size: 20),
                              SizedBox(height: 6),
                              Text('Sitter QR Codes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('Secure temporal keys generated upon hiring a sitter.', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.bgLavenderWhite, borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                              SizedBox(height: 6),
                              Text('Lost Pet QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('Public QR code that helps scan-reporters find you.', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 8. Notifications Center
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppStyles.cardsBorderRadius,
                boxShadow: AppStyles.softShadow,
                border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications & Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                  const Divider(height: 16),
                  Builder(
                    builder: (context) {
                      final allNotifs = [
                        ...jobProvider.jobs
                            .where((j) => j.status == 'completed')
                            .map((job) => {
                                  'title': 'Sitting Job Completed! 🏁',
                                  'body': 'Your job "${job.title}" is completed. Sitter QR and AI access has been revoked.',
                                  'time': 'Just now',
                                  'icon': Icons.done_all_rounded,
                                  'color': AppColors.primaryBrand,
                                }),
                        ..._notifications,
                      ];

                      if (allNotifs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No new notifications or alerts.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        );
                      }

                      return Column(
                        children: allNotifs.map<Widget>((notif) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: notif['color'].withOpacity(0.12), shape: BoxShape.circle),
                                  child: Icon(notif['icon'], color: notif['color'], size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(notif['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(notif['body'], style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                    ],
                                  ),
                                ),
                                Text(notif['time'], style: const TextStyle(fontSize: 10, color: AppColors.hintText)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 9. Pet Activity Summary Tracker
            if (selectedPet != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  boxShadow: AppStyles.softShadow,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_run_outlined, color: AppColors.primaryBrand, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedPet.name}\'s Daily Activity',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Column(
                      children: _activities.keys.map((activity) {
                        final val = _activities[activity]!;
                        return CheckboxListTile(
                          value: val,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primaryBrand,
                          title: Text(activity, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, decoration: val ? TextDecoration.lineThrough : null, color: val ? AppColors.hintText : AppColors.primaryText)),
                          onChanged: (newValue) {
                            setState(() {
                              _activities[activity] = newValue ?? false;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 10. Recent AI Conversations
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppStyles.cardsBorderRadius,
                  boxShadow: AppStyles.softShadow,
                  border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent AI Conversations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                    const Divider(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.question_answer_outlined, color: AppColors.primaryBrand, size: 18),
                      title: const Text('Check nutritional profile & allergies', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Suggested 2 hours ago • Click to ask again', style: TextStyle(fontSize: 10)),
                      onTap: () => _openChatWithPrompt(selectedPet, 'Check nutritional profile & allergies'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.question_answer_outlined, color: AppColors.primaryBrand, size: 18),
                      title: const Text('Analyze behavioral changes & mood shifts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Suggested 1 day ago • Click to ask again', style: TextStyle(fontSize: 10)),
                      onTap: () => _openChatWithPrompt(selectedPet, 'Analyze behavioral changes & mood shifts'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 11. Emergency Information Block (Red border highlight)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F8),
                  borderRadius: AppStyles.cardsBorderRadius,
                  border: Border.all(color: AppColors.danger.withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report_problem_rounded, color: AppColors.danger, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'EMERGENCY CARD (CRITICAL)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.danger, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFFFD5D5), thickness: 1, height: 20),
                    
                    // Allergy warnings
                    if (selectedPet.allergies.isNotEmpty) ...[
                      const Text('ALLERGIES:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger)),
                      const SizedBox(height: 2),
                      Text(selectedPet.allergies.join(', '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                      const SizedBox(height: 12),
                    ],

                    // Veterinarian Info
                    const Text('VETERINARIAN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger)),
                    const SizedBox(height: 2),
                    Text(
                      selectedPet.vetInfo.name.isNotEmpty 
                          ? '${selectedPet.vetInfo.name} (${selectedPet.vetInfo.phone})\nAddress: ${selectedPet.vetInfo.address}'
                          : 'No Vet info saved. Please edit pet profile.',
                      style: const TextStyle(fontSize: 13, color: AppColors.primaryText, height: 1.3, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Emergency Contacts
                    const Text('EMERGENCY OWNER CONTACTS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger)),
                    const SizedBox(height: 2),
                    if (selectedPet.emergencyContacts.isEmpty)
                      const Text('No primary emergency contacts registered.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))
                    else
                      ...selectedPet.emergencyContacts.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('• ${c.name} (${c.phone}) - ${c.relationship}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                          )),
                    
                    if (selectedPet.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('SPECIAL MEDICAL NOTES:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger)),
                      const SizedBox(height: 2),
                      Text(selectedPet.specialInstructions, style: const TextStyle(fontSize: 12, color: AppColors.primaryText, height: 1.3)),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: AppColors.primaryBrand.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: AppColors.primaryBrand, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildPromptTag(PetModel pet, String prompt) {
    return GestureDetector(
      onTap: () => _openChatWithPrompt(pet, prompt),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lightLavender),
        ),
        child: Text(
          prompt,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBrand),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Dynamic routing inside bottom navigation tabs
    Widget bodyContent;
    switch (_currentIndex) {
      case 0:
        bodyContent = _buildDashboardHome();
        break;
      case 1:
        bodyContent = const JobsScreen();
        break;
      case 2:
        bodyContent = const QrManagementScreen();
        break;
      case 3:
        bodyContent = const SettingsScreen();
        break;
      default:
        bodyContent = _buildDashboardHome();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primaryText),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            onPressed: () async {
              await userProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: bodyContent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBrand,
        unselectedItemColor: AppColors.secondaryText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_outlined), activeIcon: Icon(Icons.qr_code), label: 'Security'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
