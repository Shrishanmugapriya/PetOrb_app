import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/job_provider.dart';
import 'job_details_screen.dart';

class BrowseJobsScreen extends StatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  State<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends State<BrowseJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchJobs(assigned: false);
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
            await jobProvider.fetchJobs(assigned: false);
          },
          color: AppColors.primaryBrand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Text(
                  'Available Sitting Jobs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                ),
              ),
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
                                    const Text('🔎', style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 12),
                                    const Text('No jobs available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    const Text('Check back later for new pet sitting listings.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                      MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                            Text(
                                              '₹${job.payment.toStringAsFixed(0)}',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryBrand),
                                            ),
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
                                        
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('PETS INVOLVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.hintText, letterSpacing: 0.5)),
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
                                                const Text('DATES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.hintText, letterSpacing: 0.5)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${job.startDate.toString().split(' ')[0]} to ${job.endDate.toString().split(' ')[0]}',
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Tap to view details & apply',
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
