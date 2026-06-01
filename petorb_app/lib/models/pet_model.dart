class PetModel {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final double weight;
  final String photo;

  // Medical Information
  final List<VaccinationRecord> vaccinationRecords;
  final List<MedicalHistoryRecord> medicalHistory;
  final List<String> allergies;
  final List<Medication> currentMedications;
  final VetInfo vetInfo;

  // Care Information
  final List<FeedingScheduleItem> feedingSchedule;
  final List<String> foodPreferences;
  final String sleepSchedule;
  final String activityRoutine;
  final String behaviourNotes;

  // Emergency Information
  final List<EmergencyContact> emergencyContacts;
  final String specialInstructions;

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    this.photo = '',
    this.vaccinationRecords = const [],
    this.medicalHistory = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    required this.vetInfo,
    this.feedingSchedule = const [],
    this.foodPreferences = const [],
    this.sleepSchedule = '',
    this.activityRoutine = '',
    this.behaviourNotes = '',
    this.emergencyContacts = const [],
    this.specialInstructions = '',
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    var med = json['medicalRecords'] ?? {};
    
    var vacList = (med['vaccinationRecords'] as List?)?.map((x) => VaccinationRecord.fromJson(x)).toList() ?? [];
    var histList = (med['medicalHistory'] as List?)?.map((x) => MedicalHistoryRecord.fromJson(x)).toList() ?? [];
    var allergyList = (med['allergies'] as List?)?.map((x) => x.toString()).toList() ?? [];
    var medsList = (med['currentMedications'] as List?)?.map((x) => Medication.fromJson(x)).toList() ?? [];
    var vInfo = med['vetInfo'] != null ? VetInfo.fromJson(med['vetInfo']) : VetInfo();

    var feedList = (json['feedingSchedule'] as List?)?.map((x) => FeedingScheduleItem.fromJson(x)).toList() ?? [];
    var foodPrefs = (json['foodPreferences'] as List?)?.map((x) => x.toString()).toList() ?? [];
    
    var contacts = (json['emergencyContacts'] as List?)?.map((x) => EmergencyContact.fromJson(x)).toList() ?? [];

    return PetModel(
      id: json['_id'] ?? json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      photo: json['photo'] ?? '',
      vaccinationRecords: vacList,
      medicalHistory: histList,
      allergies: allergyList,
      currentMedications: medsList,
      vetInfo: vInfo,
      feedingSchedule: feedList,
      foodPreferences: foodPrefs,
      sleepSchedule: json['sleepSchedule'] ?? '',
      activityRoutine: json['activityRoutine'] ?? '',
      behaviourNotes: json['behaviourNotes'] ?? '',
      emergencyContacts: contacts,
      specialInstructions: json['specialInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'weight': weight,
      'photo': photo,
      'medicalRecords': {
        'vaccinationRecords': vaccinationRecords.map((x) => x.toJson()).toList(),
        'medicalHistory': medicalHistory.map((x) => x.toJson()).toList(),
        'allergies': allergies,
        'currentMedications': currentMedications.map((x) => x.toJson()).toList(),
        'vetInfo': vetInfo.toJson(),
      },
      'feedingSchedule': feedingSchedule.map((x) => x.toJson()).toList(),
      'foodPreferences': foodPreferences,
      'sleepSchedule': sleepSchedule,
      'activityRoutine': activityRoutine,
      'behaviourNotes': behaviourNotes,
      'emergencyContacts': emergencyContacts.map((x) => x.toJson()).toList(),
      'specialInstructions': specialInstructions,
    };
  }
}

class VaccinationRecord {
  final String vaccineName;
  final DateTime? dateAdministered;
  final DateTime? nextDueDate;

  VaccinationRecord({
    this.vaccineName = '',
    this.dateAdministered,
    this.nextDueDate,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      vaccineName: json['vaccineName'] ?? '',
      dateAdministered: json['dateAdministered'] != null ? DateTime.tryParse(json['dateAdministered']) : null,
      nextDueDate: json['nextDueDate'] != null ? DateTime.tryParse(json['nextDueDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccineName': vaccineName,
      if (dateAdministered != null) 'dateAdministered': dateAdministered!.toIso8601String(),
      if (nextDueDate != null) 'nextDueDate': nextDueDate!.toIso8601String(),
    };
  }
}

class MedicalHistoryRecord {
  final String condition;
  final DateTime? diagnosedDate;
  final String notes;

  MedicalHistoryRecord({
    this.condition = '',
    this.diagnosedDate,
    this.notes = '',
  });

  factory MedicalHistoryRecord.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryRecord(
      condition: json['condition'] ?? '',
      diagnosedDate: json['diagnosedDate'] != null ? DateTime.tryParse(json['diagnosedDate']) : null,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      if (diagnosedDate != null) 'diagnosedDate': diagnosedDate!.toIso8601String(),
      'notes': notes,
    };
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;

  Medication({
    this.name = '',
    this.dosage = '',
    this.frequency = '',
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
    };
  }
}

class VetInfo {
  final String name;
  final String phone;
  final String address;

  VetInfo({
    this.name = '',
    this.phone = '',
    this.address = '',
  });

  factory VetInfo.fromJson(Map<String, dynamic> json) {
    return VetInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}

class FeedingScheduleItem {
  final String time;
  final String foodType;
  final String amount;

  FeedingScheduleItem({
    this.time = '',
    this.foodType = '',
    this.amount = '',
  });

  factory FeedingScheduleItem.fromJson(Map<String, dynamic> json) {
    return FeedingScheduleItem(
      time: json['time'] ?? '',
      foodType: json['foodType'] ?? '',
      amount: json['amount'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'foodType': foodType,
      'amount': amount,
    };
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    this.name = '',
    this.phone = '',
    this.relationship = '',
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}
