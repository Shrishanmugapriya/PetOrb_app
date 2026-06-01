import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/job_model.dart';
import '../../providers/job_provider.dart';

class ApplicationsScreen extends StatefulWidget {
  final JobModel job;

  const ApplicationsScreen({super.key, required this.job});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchApplicants(widget.job.id);
    });
  }

  Future<void> _hireSitter(String appId, String sitterName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hire Caregiver?'),
        content: Text('Are you sure you want to assign this job to $sitterName? This will close application reviews and generate secure check-in QR codes.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Hire Sitter', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      try {
        await jobProvider.acceptApplicant(appId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hired $sitterName successfully! Check the QR Security Center for access keys.'), backgroundColor: AppColors.success),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Applicants', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Job brief card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Budget Offered: ₹${widget.job.payment.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primaryBrand, fontWeight: FontWeight.bold, fontSize: 13)),
                  if (widget.job.status == 'assigned') ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                              SizedBox(width: 6),
                              Text('Sitter Hired & Assigned', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Complete Sitting Job?'),
                                content: const Text('Are you sure this sitting job is completed? This will revoke the sitter\'s QR access keys and disable their AI Care Assistant access for your pets.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Complete', style: TextStyle(color: AppColors.primaryBrand, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await Provider.of<JobProvider>(context, listen: false).completeJob(widget.job.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Job marked as Completed! Sitter access has been stopped.'), backgroundColor: AppColors.primaryBrand),
                                );
                                Navigator.of(context).pop();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: AppColors.danger),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.done_all_rounded, size: 16, color: Colors.white),
                          label: const Text('Complete Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrand,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.job.status == 'completed') ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primaryBrand.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.done_all_rounded, color: AppColors.primaryBrand, size: 16),
                          SizedBox(width: 6),
                          Text('Job Completed', style: TextStyle(color: AppColors.primaryBrand, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),

            // Applicants feed
            Expanded(
              child: jobProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
                  : jobProvider.applicants.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🙋‍♂️', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 12),
                              Text('No applications yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('We\'ll alert you as soon as sitters apply.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: jobProvider.applicants.length,
                          itemBuilder: (context, index) {
                            final app = jobProvider.applicants[index];
                            final sitterName = app.sitter?.name ?? 'Caregiver';
                            final experience = app.experience.isNotEmpty ? app.experience : 'No experience notes added';
                            final bio = app.sitter?.sitterProfile?.bio ?? 'No bio added.';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppStyles.cardsBorderRadius,
                                side: BorderSide(color: AppColors.lightLavender.withOpacity(0.5)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sitter identity Header
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage: app.sitter?.photo.isNotEmpty == true ? NetworkImage(app.sitter!.photo) : null,
                                          backgroundColor: AppColors.primaryBrand.withOpacity(0.1),
                                          child: app.sitter?.photo.isEmpty == true ? const Icon(Icons.person, color: AppColors.primaryBrand) : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(sitterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              Text(app.sitter?.email ?? '', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '₹${app.proposedRate.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryBrand),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    
                                    const Text('Bio / Experience Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryText)),
                                    const SizedBox(height: 4),
                                    Text(bio, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.3)),
                                    const SizedBox(height: 10),
                                    const Text('Sitting Pitch:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryText)),
                                    const SizedBox(height: 4),
                                    Text(experience, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.3)),
                                    
                                    const Divider(height: 24),
                                    
                                    // Action buttons (Only show if job is open and application is pending)
                                    if (widget.job.status == 'open' && app.status == 'pending')
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              await jobProvider.rejectApplicant(app.id);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.danger,
                                              side: const BorderSide(color: AppColors.danger),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () => _hireSitter(app.id, sitterName),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryBrand,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('Hire Sitter', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      )
                                    else
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          app.status.toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: app.status == 'accepted' ? AppColors.success : AppColors.danger,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
