import 'user_model.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String sitterId;
  final String status; // 'pending', 'accepted', 'rejected'
  final String experience;
  final double proposedRate;
  final UserModel? sitter;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.sitterId,
    required this.status,
    this.experience = '',
    required this.proposedRate,
    this.sitter,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['_id'] ?? json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      sitterId: json['sitterId'] ?? '',
      status: json['status'] ?? 'pending',
      experience: json['experience'] ?? '',
      proposedRate: (json['proposedRate'] ?? 0.0).toDouble(),
      sitter: json['sitter'] != null ? UserModel.fromJson(json['sitter']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'proposedRate': proposedRate,
    };
  }
}
