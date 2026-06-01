import 'pet_model.dart';

class JobModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final List<String> petIds;
  final List<PetModel> pets;
  final String title;
  final String description;
  final double payment;
  final String status; // 'open', 'assigned', 'completed', 'cancelled'
  final DateTime startDate;
  final DateTime endDate;
  final String instructions;
  final String? assignedSitterId;

  JobModel({
    required this.id,
    required this.ownerId,
    this.ownerName = 'Pet Owner',
    required this.petIds,
    this.pets = const [],
    required this.title,
    required this.description,
    required this.payment,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.instructions = '',
    this.assignedSitterId,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    var rawPets = json['petIds'] as List? ?? [];
    List<PetModel> parsedPets = [];
    List<String> parsedPetIds = [];

    for (var p in rawPets) {
      if (p is Map<String, dynamic>) {
        parsedPets.add(PetModel.fromJson(p));
        parsedPetIds.add(p['_id'] ?? p['id'] ?? '');
      } else if (p is String) {
        parsedPetIds.add(p);
      }
    }

    return JobModel(
      id: json['_id'] ?? json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? 'Pet Owner',
      petIds: parsedPetIds,
      pets: parsedPets,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      payment: (json['payment'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'open',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      instructions: json['instructions'] ?? '',
      assignedSitterId: json['assignedSitterId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petIds': petIds,
      'title': title,
      'description': description,
      'payment': payment,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'instructions': instructions,
    };
  }
}
