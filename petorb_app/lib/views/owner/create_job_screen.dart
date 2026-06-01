import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/job_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/job_provider.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _paymentController = TextEditingController();
  final _instructionsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedPetIds = [];

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBrand,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPetIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one pet'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select sitting start and end dates'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    final jobData = JobModel(
      id: '',
      ownerId: '',
      petIds: _selectedPetIds,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      payment: double.tryParse(_paymentController.text.trim()) ?? 0.0,
      status: 'open',
      startDate: _startDate!,
      endDate: _endDate!,
      instructions: _instructionsController.text.trim(),
    );

    try {
      await jobProvider.createJob(jobData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted to Marketplace successfully!'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: AppColors.danger),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.hintText),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.secondaryText) : null,
            filled: true,
            fillColor: AppColors.bgLavenderWhite.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: AppStyles.inputsBorderRadius,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: AppStyles.inputsBorderRadius,
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Sitting Job',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText),
        ),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Job Title *',
                        hint: 'e.g. Weekend dog sitting for Bruno',
                        prefixIcon: Icons.work_outline,
                        validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                      ),
                      _buildTextField(
                        controller: _descController,
                        label: 'Description *',
                        hint: 'Explain sitting needs, activities, etc.',
                        maxLines: 4,
                        validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
                      ),

                      // Selected Pets Checkboxes
                      const Text(
                        'Select Pets for Care *',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      if (petProvider.pets.isEmpty)
                        const Text('No pets registered. Please create a pet profile first.', style: TextStyle(color: AppColors.danger, fontSize: 12))
                      else
                        ...petProvider.pets.map((pet) {
                          final isChecked = _selectedPetIds.contains(pet.id);
                          return CheckboxListTile(
                            title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(pet.breed),
                            value: isChecked,
                            activeColor: AppColors.primaryBrand,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedPetIds.add(pet.id);
                                } else {
                                  _selectedPetIds.remove(pet.id);
                                }
                              });
                            },
                          );
                        }),
                      const SizedBox(height: 16),

                      // Date Range picker button
                      const Text(
                        'Sitting Schedule *',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.lightLavender),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: AppStyles.inputsBorderRadius),
                        ),
                        icon: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryBrand),
                        label: Text(
                          _startDate == null
                              ? 'Select Date Range'
                              : '${_startDate.toString().split(' ')[0]}  to  ${_endDate.toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _paymentController,
                        label: 'Payment Offer (INR) *',
                        hint: 'e.g. 1500',
                        prefixIcon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Payment rate is required' : null,
                      ),
                      _buildTextField(
                        controller: _instructionsController,
                        label: 'Special Instructions',
                        hint: 'e.g. Sitter must walk Rocky before feeding',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button Bar
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
                          onPressed: _submitJob,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: AppStyles.buttonsBorderRadius),
                          ),
                          child: const Text('Post Job Listing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
