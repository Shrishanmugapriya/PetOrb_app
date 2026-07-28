import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';

class AddEditPetScreen extends StatefulWidget {
  final PetModel? pet; // Null means adding new pet

  const AddEditPetScreen({super.key, this.pet});

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Basic Controllers
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _weightController = TextEditingController();
  final _photoController = TextEditingController();

  // Medical Controllers
  final _allergiesController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _vetPhoneController = TextEditingController();
  final _vetAddressController = TextEditingController();

  // Care Controllers
  final _foodPrefsController = TextEditingController();
  final _sleepScheduleController = TextEditingController();
  final _activityController = TextEditingController();
  final _behaviorController = TextEditingController();

  // Emergency Controllers
  final _instructionsController = TextEditingController();

  // Dynamic Lists for sub-records
  List<VaccinationRecord> _vaccineRecords = [];
  List<MedicalHistoryRecord> _historyRecords = [];
  List<Medication> _medications = [];
  List<FeedingScheduleItem> _feedingSchedule = [];
  List<EmergencyContact> _emergencyContacts = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 60,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
        setState(() {
          _photoController.text = base64Image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Pet Photo Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryBrand),
                title: const Text('Upload PNG / JPG File from Device', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select photo file from gallery or storage', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryBrand),
                title: const Text('Capture Live Camera Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Take a photo using live camera', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool get isEdit => widget.pet != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    if (isEdit) {
      final pet = widget.pet!;
      _nameController.text = pet.name;
      _speciesController.text = pet.species;
      _breedController.text = pet.breed;
      _ageController.text = pet.age.toString();
      _genderController.text = pet.gender;
      _weightController.text = pet.weight.toString();
      _photoController.text = pet.photo;

      _allergiesController.text = pet.allergies.join(', ');
      _vetNameController.text = pet.vetInfo.name;
      _vetPhoneController.text = pet.vetInfo.phone;
      _vetAddressController.text = pet.vetInfo.address;

      _foodPrefsController.text = pet.foodPreferences.join(', ');
      _sleepScheduleController.text = pet.sleepSchedule;
      _activityController.text = pet.activityRoutine;
      _behaviorController.text = pet.behaviourNotes;

      _instructionsController.text = pet.specialInstructions;

      _vaccineRecords = List.from(pet.vaccinationRecords);
      _historyRecords = List.from(pet.medicalHistory);
      _medications = List.from(pet.currentMedications);
      _feedingSchedule = List.from(pet.feedingSchedule);
      _emergencyContacts = List.from(pet.emergencyContacts);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct errors on form fields'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final petProvider = Provider.of<PetProvider>(context, listen: false);

    // Prepare lists from comma-separated inputs
    List<String> allergies = _allergiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    List<String> foodPreferences = _foodPrefsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final petData = PetModel(
      id: isEdit ? widget.pet!.id : '',
      ownerId: isEdit ? widget.pet!.ownerId : '',
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _genderController.text.trim(),
      weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
      photo: _photoController.text.trim(),
      vaccinationRecords: _vaccineRecords,
      medicalHistory: _historyRecords,
      allergies: allergies,
      currentMedications: _medications,
      vetInfo: VetInfo(
        name: _vetNameController.text.trim(),
        phone: _vetPhoneController.text.trim(),
        address: _vetAddressController.text.trim(),
      ),
      feedingSchedule: _feedingSchedule,
      foodPreferences: foodPreferences,
      sleepSchedule: _sleepScheduleController.text.trim(),
      activityRoutine: _activityController.text.trim(),
      behaviourNotes: _behaviorController.text.trim(),
      emergencyContacts: _emergencyContacts,
      specialInstructions: _instructionsController.text.trim(),
    );

    try {
      if (isEdit) {
        await petProvider.updatePet(widget.pet!.id, petData);
      } else {
        await petProvider.addPet(petData);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${petData.name} saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Pet Profile' : 'Add New Pet',
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBrand,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primaryBrand,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Medical'),
            Tab(text: 'Care'),
            Tab(text: 'Emergency'),
          ],
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
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Basic Information
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Pet Name *',
                            hint: 'e.g. Bruno',
                            prefixIcon: Icons.pets,
                            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                          ),
                          _buildTextField(
                            controller: _speciesController,
                            label: 'Species *',
                            hint: 'e.g. Dog, Cat, Rabbit',
                            prefixIcon: Icons.category_outlined,
                            validator: (v) => v == null || v.isEmpty ? 'Species is required' : null,
                          ),
                          _buildTextField(
                            controller: _breedController,
                            label: 'Breed *',
                            hint: 'e.g. Golden Retriever',
                            prefixIcon: Icons.history_edu,
                            validator: (v) => v == null || v.isEmpty ? 'Breed is required' : null,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _ageController,
                                  label: 'Age (Years) *',
                                  hint: 'e.g. 3',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || v.isEmpty ? 'Age required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _genderController,
                                  label: 'Gender *',
                                  hint: 'Male/Female',
                                  validator: (v) => v == null || v.isEmpty ? 'Gender required' : null,
                                ),
                              ),
                            ],
                          ),
                          _buildTextField(
                            controller: _weightController,
                            label: 'Weight (kg) *',
                            hint: 'e.g. 28.5',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Weight required' : null,
                          ),
                          // Interactive Pet Photo Selector (PNG file upload / Live camera capture)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pet Photo Image *',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.bgLavenderWhite.withOpacity(0.6),
                                borderRadius: AppStyles.cardsBorderRadius,
                                border: Border.all(color: AppColors.primaryBrand.withOpacity(0.3), width: 1.5),
                              ),
                              child: _photoController.text.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: AppStyles.cardsBorderRadius,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: _photoController.text.startsWith('data:image')
                                                ? Image.memory(
                                                    base64Decode(_photoController.text.split(',').last),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    _photoController.text,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.pets, size: 40, color: AppColors.primaryBrand)),
                                                  ),
                                          ),
                                          Positioned(
                                            right: 8,
                                            bottom: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.65),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.edit, color: Colors.white, size: 14),
                                                  SizedBox(width: 4),
                                                  Text('Change Photo', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () => _pickImage(ImageSource.gallery),
                                              icon: const Icon(Icons.upload_file_rounded, size: 18),
                                              label: const Text('Upload PNG File'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primaryBrand,
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            OutlinedButton.icon(
                                              onPressed: () => _pickImage(ImageSource.camera),
                                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                                              label: const Text('Live Camera'),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Upload a PNG/JPG photo file or take a live picture',
                                          style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Tab 2: Medical Information
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _allergiesController,
                            label: 'Allergies & Restrictions (comma-separated)',
                            hint: 'e.g. Chicken, Penicillin, Dust allergies',
                            prefixIcon: Icons.warning_amber_rounded,
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Veterinary Information',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _vetNameController,
                            label: 'Vet Clinic Name',
                            hint: 'e.g. Happy Paws Vet Clinic',
                          ),
                          _buildTextField(
                            controller: _vetPhoneController,
                            label: 'Vet Phone Number',
                            hint: 'e.g. +91 99999 88888',
                            keyboardType: TextInputType.phone,
                          ),
                          _buildTextField(
                            controller: _vetAddressController,
                            label: 'Vet Address',
                            hint: 'e.g. 104 Park Avenue Road',
                          ),
                          const Divider(height: 32),
                          
                          // Helper to add vaccine records
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Vaccination Log',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _vaccineRecords.add(VaccinationRecord(
                                      vaccineName: 'Rabies booster',
                                      dateAdministered: DateTime.now(),
                                      nextDueDate: DateTime.now().add(const Duration(days: 365)),
                                    ));
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Vaccine'),
                              ),
                            ],
                          ),
                          if (_vaccineRecords.isEmpty)
                            const Text('No vaccination records added.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                          ...List.generate(_vaccineRecords.length, (index) {
                            final rec = _vaccineRecords[index];
                            return ListTile(
                              title: Text(rec.vaccineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Administered: ${rec.dateAdministered.toString().split(' ')[0]}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                onPressed: () {
                                  setState(() {
                                    _vaccineRecords.removeAt(index);
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // Tab 3: Care & Feeding
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _foodPrefsController,
                            label: 'Food Preferences (comma-separated)',
                            hint: 'e.g. Dry kibble, Salmon flavor, Wet food',
                            prefixIcon: Icons.restaurant,
                          ),
                          _buildTextField(
                            controller: _sleepScheduleController,
                            label: 'Sleep Schedule Notes',
                            hint: 'e.g. Sleeps 10 PM to 7 AM on dog bed',
                          ),
                          _buildTextField(
                            controller: _activityController,
                            label: 'Activity Routine',
                            hint: 'e.g. Walks twice daily for 20 mins',
                          ),
                          _buildTextField(
                            controller: _behaviorController,
                            label: 'Behavioral Notes',
                            hint: 'e.g. Timid around new people, barks at birds',
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Feeding Schedule Logs',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _feedingSchedule.add(FeedingScheduleItem(
                                      time: '08:00 AM',
                                      foodType: 'Dry Kibble',
                                      amount: '1 Cup',
                                    ));
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Log'),
                              ),
                            ],
                          ),
                          if (_feedingSchedule.isEmpty)
                            const Text('No schedules configured.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                          ...List.generate(_feedingSchedule.length, (index) {
                            final log = _feedingSchedule[index];
                            return ListTile(
                              title: Text('${log.time} - ${log.foodType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Serving Size: ${log.amount}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                onPressed: () {
                                  setState(() {
                                    _feedingSchedule.removeAt(index);
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // Tab 4: Emergency Contacts & Rescue
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _instructionsController,
                            label: 'Special / Lost Recovery Instructions',
                            hint: 'e.g. If lost, Rocky responds to whistling. He has medication guidelines.',
                            prefixIcon: Icons.announcement_outlined,
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Emergency Contacts',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _emergencyContacts.add(EmergencyContact(
                                      name: 'Uncle Sam',
                                      phone: '+91 99999 77777',
                                      relationship: 'Neighbor',
                                    ));
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Contact'),
                              ),
                            ],
                          ),
                          if (_emergencyContacts.isEmpty)
                            const Text('No secondary emergency contacts added.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                          ...List.generate(_emergencyContacts.length, (index) {
                            final contact = _emergencyContacts[index];
                            return ListTile(
                              title: Text('${contact.name} (${contact.relationship})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Call: ${contact.phone}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                onPressed: () {
                                  setState(() {
                                    _emergencyContacts.removeAt(index);
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom action bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: petProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.mainGradient,
                          borderRadius: AppStyles.buttonsBorderRadius,
                        ),
                        child: ElevatedButton(
                          onPressed: _savePet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppStyles.buttonsBorderRadius,
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Create Profile',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
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
