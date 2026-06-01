import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/job_provider.dart';
import 'create_job_screen.dart';
import 'applications_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await jobProvider.fetchJobs();
          },
          color: AppColors.primaryBrand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Marketplace Listings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateJobScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Post Job', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Listings list
              Expanded(
                child: jobProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
                    : jobProvider.jobs.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 100),
                              Center(
                                child: Column(
                                  children: [
                                    const Text('💼', style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 12),
                                    const Text('No jobs posted yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    const Text('Tap "Post Job" to find a trusted caregiver.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: jobProvider.jobs.length,
                            itemBuilder: (context, index) {
                              final job = jobProvider.jobs[index];
                              final totalPets = job.petIds.length;
                              final petsStr = job.pets.map((p) => p.name).join(', ');

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppStyles.cardsBorderRadius,
                                  side: BorderSide(color: AppColors.lightLavender.withOpacity(0.5)),
                                ),
                                child: InkWell(
                                  borderRadius: AppStyles.cardsBorderRadius,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => ApplicationsScreen(job: job)),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Title & Status
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                job.title,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryText),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: job.status == 'open' ? AppColors.primaryBrand.withOpacity(0.12) : AppColors.success.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                job.status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: job.status == 'open' ? AppColors.primaryBrand : AppColors.success,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          job.description,
                                          style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Divider(height: 24),
                                        
                                        // Metrics details
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('PETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.hintText, letterSpacing: 0.5)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  totalPets > 0 ? (petsStr.isNotEmpty ? petsStr : '$totalPets pets') : 'None',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('BUDGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.hintText, letterSpacing: 0.5)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '₹${job.payment.toStringAsFixed(0)}',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBrand),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('TIMEFRAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.hintText, letterSpacing: 0.5)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${job.startDate.toString().split(' ')[0]}',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),

                                        // View Applicants count CTA
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Tap to view applications',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBrand),
                                            ),
                                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryBrand),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
