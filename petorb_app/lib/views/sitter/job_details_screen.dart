import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/job_model.dart';
import '../../providers/job_provider.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _rateController = TextEditingController();
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _rateController.text = widget.job.payment.toStringAsFixed(0);
    // Simple state mapping check (can expand with checking user's application lists on backend)
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    try {
      await jobProvider.applyForJob(
        widget.job.id,
        _experienceController.text.trim(),
        double.tryParse(_rateController.text.trim()) ?? widget.job.payment,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!'), backgroundColor: AppColors.success),
      );
      setState(() {
        _hasApplied = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText)),
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
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Job Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppStyles.cardsBorderRadius,
                          border: Border.all(color: AppColors.lightLavender.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.job.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryText)),
                            const SizedBox(height: 6),
                            Text(
                              'Budget Offered: ₹${widget.job.payment.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.primaryBrand, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Divider(height: 24),
                            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                            const SizedBox(height: 4),
                            Text(widget.job.description, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.4)),
                            const SizedBox(height: 16),
                            const Text('Schedule dates:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryText)),
                            const SizedBox(height: 4),
                            Text(
                              '📆 ${widget.job.startDate.toString().split(' ')[0]}  to  ${widget.job.endDate.toString().split(' ')[0]}',
                              style: const TextStyle(color: AppColors.secondaryText, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Selected Pets list
                      const Text(
                        'Pets Needing Care',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      const SizedBox(height: 8),
                      if (widget.job.pets.isEmpty)
                        const Text('No pet details populated.', style: TextStyle(color: AppColors.secondaryText, fontSize: 12))
                      else
                        ...widget.job.pets.map((pet) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.lightLavender.withOpacity(0.4))),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: pet.photo.isNotEmpty ? NetworkImage(pet.photo) : null,
                                child: pet.photo.isEmpty ? const Icon(Icons.pets) : null,
                              ),
                              title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${pet.species} • ${pet.breed} • ${pet.age} Yrs'),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),

                      // Instructions
                      if (widget.job.instructions.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.assignment_turned_in_outlined, color: Colors.amber, size: 18),
                                  SizedBox(width: 6),
                                  Text('Owner Sitting Instructions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(widget.job.instructions, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.3)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Form input if open
                      if (widget.job.status == 'open' && !_hasApplied) ...[
                        const Text('Submit Your Application Bid', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                        const Divider(height: 16),
                        
                        // Experience Pitch
                        const Text(
                          'Your Experience / Care Plan Pitch *',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _experienceController,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Introduce yourself, describe experience with similar breeds, and outline your care plan.',
                            hintStyle: const TextStyle(color: AppColors.hintText),
                            filled: true,
                            fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: AppStyles.inputsBorderRadius),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: AppStyles.inputsBorderRadius),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Please pitch your experience' : null,
                        ),
                        const SizedBox(height: 16),

                        // Bid rate
                        const Text(
                          'Proposed Sitting Rate (INR) *',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _rateController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.secondaryText),
                            filled: true,
                            fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: AppStyles.inputsBorderRadius),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: AppStyles.inputsBorderRadius),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Rate is required' : null,
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: const Column(
                            children: [
                              Icon(Icons.done_all, color: AppColors.success, size: 28),
                              SizedBox(height: 8),
                              Text('Application Submitted!', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                              SizedBox(height: 2),
                              Text('The owner will review your pitch and rate.', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Action Button
            if (widget.job.status == 'open' && !_hasApplied)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
                  ],
                ),
                child: jobProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.mainGradient,
                          borderRadius: AppStyles.buttonsBorderRadius,
                        ),
                        child: ElevatedButton(
                          onPressed: _submitApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: AppStyles.buttonsBorderRadius),
                          ),
                          child: const Text('Apply for Sitting Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
