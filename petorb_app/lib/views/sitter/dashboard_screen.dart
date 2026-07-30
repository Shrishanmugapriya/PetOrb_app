import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/job_provider.dart';
import '../../models/pet_model.dart';
import '../../models/job_model.dart';
import '../auth/login_screen.dart';
import 'browse_jobs_screen.dart';
import 'qr_scanner_screen.dart';
import 'assigned_pets_screen.dart';
import 'ai_assistant_screen.dart';
import '../shared/logo_widget.dart';
import '../shared/about_screen.dart';
import '../shared/settings_screen.dart';

class SitterDashboardScreen extends StatefulWidget {
  const SitterDashboardScreen({super.key});

  @override
  State<SitterDashboardScreen> createState() => _SitterDashboardScreenState();
}

class _SitterDashboardScreenState extends State<SitterDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = ['Dashboard', 'Browse Jobs', 'Settings'];

  // 8. Notification Center alert stream for sitters
  final List<Map<String, dynamic>> _notifications = [];

  // 9. Sitting History logs
  final List<Map<String, dynamic>> _sittingHistory = [];

  // 10. Sitter skills, availability, hourly rates
  final List<String> _skills = [];
  bool _availableNow = true;
  final String _certifications = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).fetchPets();
      Provider.of<JobProvider>(context, listen: false).fetchJobs(assigned: true);
      Provider.of<JobProvider>(context, listen: false).fetchJobs(assigned: false); // Load open jobs
    });
  }

  Widget _buildDashboardHome() {
    final userProvider = Provider.of<UserProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    final name = userProvider.currentUser?.name ?? 'Sitter';
    final photo = userProvider.currentUser?.photo ?? '';
    final hasProfileDetails = (userProvider.currentUser?.sitterProfile?.experience?.isNotEmpty ?? false) ||
                              ((userProvider.currentUser?.sitterProfile?.rate ?? 0) > 0);
    final exp = userProvider.currentUser?.sitterProfile?.experience ?? '';
    final rate = userProvider.currentUser?.sitterProfile?.rate ?? 0.0;
    final profileSubStr = hasProfileDetails
        ? 'Experience: ${exp.isNotEmpty ? exp : 'Not set'} • Rate: ₹${rate > 0 ? rate.toStringAsFixed(0) : '0'}/hr'
        : 'Update profile to add experience & rate';

    final totalAssignedPets = petProvider.pets.length;
    final isNewUser = totalAssignedPets == 0 && (jobProvider.assignedJobs.isEmpty);
    final welcomeTitle = isNewUser ? 'Welcome to PetOrb, $name! 🙋‍♂️' : 'Welcome back, $name! 🙋‍♂️';
    final welcomeSubText = isNewUser
        ? 'Explore open sitting jobs in your area to get started.'
        : 'You are currently assigned to $totalAssignedPets ${totalAssignedPets == 1 ? 'pet' : 'pets'}.';

    // Combine completed jobs and static sitting history
    final completedJobs = jobProvider.assignedJobs.where((j) => j.status == 'completed').toList();
    final List<Map<String, dynamic>> combinedHistory = [];
    for (var job in completedJobs) {
      final petsStr = job.pets.map((p) => p.name).join(', ');
      final diff = job.endDate.difference(job.startDate).inDays;
      final durationStr = '${diff <= 0 ? 1 : diff} day${diff > 1 ? 's' : ''}';
      combinedHistory.add({
        'petName': petsStr.isNotEmpty ? petsStr : 'Pet',
        'ownerName': job.ownerName,
        'duration': durationStr,
        'rating': 5.0,
        'feedback': 'Completed Care: Hired at ₹${job.payment.toStringAsFixed(0)} listing rate.'
      });
    }
    combinedHistory.addAll(_sittingHistory);

    return RefreshIndicator(
      onRefresh: () async {
        await petProvider.fetchPets();
        await jobProvider.fetchJobs(assigned: true);
        await jobProvider.fetchJobs(assigned: false);
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
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty 
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
                            const SizedBox(height: 2),
                            Text(
                              profileSubStr,
                              style: const TextStyle(fontSize: 11, color: AppColors.lightLavender, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              welcomeSubText,
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 28),
                        tooltip: 'Switch to Owner Mode',
                        onPressed: () async {
                          await userProvider.devSwitchRole();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Switched to Owner Module!'), backgroundColor: AppColors.primaryBrand),
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

            // 5. QR Code Scanner Entry Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppStyles.cardsBorderRadius,
                boxShadow: AppStyles.softShadow,
                border: Border.all(color: AppColors.lightLavender),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppStyles.cardsBorderRadius,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrand.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryBrand, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan Sitter QR Code',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryText),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Unlock secure pet files & start caretaking duties.',
                                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryBrand),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Assigned Pets Overview
            const Text(
              'Pets in Your Care (Assigned)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
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
                          border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                        ),
                        child: const Column(
                          children: [
                            Text('🐾', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 10),
                            Text('No pets assigned yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 4),
                            Text('Scan Owner QR access keys to unlock pet records.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                          ],
                        ),
                      )
                    : Column(
                        children: petProvider.pets.map((pet) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppStyles.cardsBorderRadius,
                              side: BorderSide(color: AppColors.lightLavender.withOpacity(0.4)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryBrand.withOpacity(0.1),
                                backgroundImage: pet.photo.isNotEmpty ? NetworkImage(pet.photo) : null,
                                child: pet.photo.isEmpty ? const Icon(Icons.pets, color: AppColors.primaryBrand) : null,
                              ),
                              title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('${pet.breed} • ${pet.age} Yrs • Care Status: Active', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryBrand),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => AssignedPetDetailsScreen(pet: pet)),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
            const SizedBox(height: 20),

            // 6. AI Care Assistant Panel (restricted to assigned pets)
            if (petProvider.pets.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF1EEFF), Color(0xFFF9F8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppStyles.cardsBorderRadius,
                  border: Border.all(color: AppColors.primaryBrand.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.support_agent_rounded, color: AppColors.primaryBrand, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Caretaker AI Assistant',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Consult AI regarding diet, medication guidelines, or habits.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                    const SizedBox(height: 12),
                    const Text('Quick Care Questions:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickTag(petProvider.pets.first, 'What should I feed this pet?'),
                          _buildQuickTag(petProvider.pets.first, 'Does this pet have allergies?'),
                          _buildQuickTag(petProvider.pets.first, 'When is feeding time?'),
                          _buildQuickTag(petProvider.pets.first, 'What activities does the pet enjoy?'),
                          _buildQuickTag(petProvider.pets.first, 'Any special care instructions?'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7. Pet Care Schedule (Feeding, Medication, Sleep, Exercise)
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
                        Icon(Icons.calendar_today_outlined, color: AppColors.primaryBrand, size: 20),
                        SizedBox(width: 8),
                        Text('Detailed Care Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const Divider(height: 20),
                    // Feeding routine
                    ...petProvider.pets.take(1).map((p) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${p.name}\'s Routine:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 12)),
                          const SizedBox(height: 6),
                          if (p.feedingSchedule.isEmpty)
                            const Text('No feed timings.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText))
                          else
                            ...p.feedingSchedule.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Text('🍴 ${f.time}: ${f.foodType} (${f.amount})', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                                )),
                          const SizedBox(height: 6),
                          if (p.currentMedications.isNotEmpty) ...[
                            const Text('Medications:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 11)),
                            const SizedBox(height: 4),
                            ...p.currentMedications.map((m) => Text('💊 ${m.name} - ${m.dosage} (${m.frequency})', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                            const SizedBox(height: 6),
                          ],
                          if (p.sleepSchedule.isNotEmpty)
                            Text('😴 Sleep: ${p.sleepSchedule}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                          if (p.activityRoutine.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('🏃 Activity: ${p.activityRoutine}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 2. Available Jobs Feed Summary
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
                      const Text('Recently Posted Sitting Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 1; // Open Browse Jobs
                          });
                        },
                        child: const Text('Browse all'),
                      )
                    ],
                  ),
                  const Divider(height: 10),
                  jobProvider.jobs.isEmpty
                      ? const Text('No jobs available at the moment.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText))
                      : Column(
                          children: jobProvider.jobs.take(2).map((job) {
                            return Card(
                              margin: const EdgeInsets.only(top: 8),
                              elevation: 0,
                              color: AppColors.bgLavenderWhite,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                dense: true,
                                title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                subtitle: Text('Rate: ₹${job.payment.toStringAsFixed(0)} • Duration: ${job.startDate.toString().split(' ')[0]}', style: const TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryBrand),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => BrowseJobsScreen()), // Browse jobs tab
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

            // 3. My Applications Tracker
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
                  const Text('My Job Applications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAppStat('PENDING', '0', AppColors.warning),
                      _buildAppStat('ACCEPTED', '${jobProvider.assignedJobs.where((j) => j.status == "accepted" || j.status == "assigned").length}', AppColors.success),
                      _buildAppStat('COMPLETED', '${jobProvider.assignedJobs.where((j) => j.status == "completed").length}', AppColors.primaryBrand),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 8. Notifications Center for Sitter
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
                  const Text('Notifications & Reminders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                  const Divider(height: 16),
                  Builder(
                    builder: (context) {
                      final allNotifs = [
                        ...jobProvider.assignedJobs
                            .where((j) => j.status == 'completed')
                            .map((job) => {
                                  'title': 'Sitting Job Completed! 🏁',
                                  'body': 'Your assignment for "${job.title}" is completed. Your access to the pet\'s files has expired.',
                                  'time': 'Just now',
                                  'icon': Icons.check_circle_outline,
                                  'color': AppColors.primaryBrand,
                                }),
                        ..._notifications,
                      ];

                      if (allNotifs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No new notifications or reminders.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
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

            // 9. Sitting History & Feedback Ratings
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
                  const Text('My Sitting History & Ratings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                  const Divider(height: 16),
                  combinedHistory.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No sitting history yet. Complete sitting assignments to earn ratings and reviews!', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        )
                      : Column(
                          children: combinedHistory.map((hist) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Cared for ${hist['petName']} (${hist['duration']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 2),
                                          Text(hist['rating'].toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('"${hist['feedback']}" - ${hist['ownerName']}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic)),
                                  const Divider(height: 16),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 10. Profile Skills & Management (Read-only quick display)
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
                      const Text('Skills & Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryText)),
                      Switch(
                        value: _availableNow,
                        activeColor: AppColors.primaryBrand,
                        onChanged: (v) {
                          setState(() {
                            _availableNow = v;
                          });
                        },
                      ),
                    ],
                  ),
                  Text('Availability Status: ${_availableNow ? "AVAILABLE NOW" : "BUSY"}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _availableNow ? AppColors.success : AppColors.danger)),
                  const SizedBox(height: 8),
                  Text('Certifications: ${_certifications.isNotEmpty ? _certifications : "Not specified"}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  const Divider(height: 20),
                  _skills.isEmpty
                      ? const Text('No skills listed yet. Update your profile settings to add your skills.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _skills.map((skill) {
                            return Chip(
                              label: Text(skill, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBrand)),
                              backgroundColor: AppColors.bgLavenderWhite,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.lightLavender)),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 11. Emergency Information Block for Sitter
            if (petProvider.pets.isNotEmpty) ...[
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
                          'EMERGENCY DIRECTORY',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.danger, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFFFD5D5), thickness: 1, height: 20),
                    
                    // Show details for the first assigned pet as a quick guide
                    ...petProvider.pets.take(1).map((p) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pet: ${p.name.toUpperCase()} (ALLERGIES: ${p.allergies.isEmpty ? "None" : p.allergies.join(", ")})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.danger)),
                          const SizedBox(height: 8),
                          const Text('VETERINARIAN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger)),
                          Text(p.vetInfo.name.isNotEmpty ? '${p.vetInfo.name} (${p.vetInfo.phone})\nAddress: ${p.vetInfo.address}' : 'No Vet details recorded.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          const Text('OWNER EMERGENCY CONTACTS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.danger)),
                          if (p.emergencyContacts.isEmpty)
                            const Text('No contacts recorded.', style: TextStyle(fontSize: 11))
                          else
                            ...p.emergencyContacts.map((c) => Text('• ${c.name} (${c.phone}) - ${c.relationship}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        ],
                      );
                    }),
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

  Widget _buildQuickTag(PetModel pet, String prompt) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SitterAiAssistantScreen(pet: pet)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Consulting AI: "$prompt"'), backgroundColor: AppColors.primaryBrand),
        );
      },
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

  Widget _buildAppStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    Widget bodyContent;
    switch (_currentIndex) {
      case 0:
        bodyContent = _buildDashboardHome();
        break;
      case 1:
        bodyContent = const BrowseJobsScreen();
        break;
      case 2:
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
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), activeIcon: Icon(Icons.travel_explore), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
