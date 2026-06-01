import 'pet_model.dart';
import 'user_model.dart';

class QRAccessModel {
  final String id;
  final String petId;
  final PetModel? pet;
  final String sitterId;
  final UserModel? sitter;
  final DateTime expiryDate;
  final String token;
  final bool revoked;

  QRAccessModel({
    required this.id,
    required this.petId,
    this.pet,
    required this.sitterId,
    this.sitter,
    required this.expiryDate,
    required this.token,
    this.revoked = false,
  });

  factory QRAccessModel.fromJson(Map<String, dynamic> json) {
    return QRAccessModel(
      id: json['_id'] ?? json['id'] ?? '',
      petId: json['petId'] is Map ? (json['petId']['_id'] ?? json['petId']['id'] ?? '') : (json['petId'] ?? ''),
      pet: json['petId'] is Map ? PetModel.fromJson(json['petId']) : null,
      sitterId: json['sitterId'] ?? '',
      sitter: json['sitter'] != null ? UserModel.fromJson(json['sitter']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : DateTime.now(),
      token: json['token'] ?? '',
      revoked: json['revoked'] ?? false,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isValid => !revoked && !isExpired;
}
