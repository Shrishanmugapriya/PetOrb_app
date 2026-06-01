class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'owner' or 'sitter'
  final String photo;
  final String phone;
  final SitterProfile? sitterProfile;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photo = '',
    this.phone = '',
    this.sitterProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'owner',
      photo: json['photo'] ?? '',
      phone: json['phone'] ?? '',
      sitterProfile: json['sitterProfile'] != null 
          ? SitterProfile.fromJson(json['sitterProfile']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'photo': photo,
      'phone': phone,
      if (sitterProfile != null) 'sitterProfile': sitterProfile!.toJson(),
    };
  }
}

class SitterProfile {
  final String experience;
  final String bio;
  final double rate;
  final bool verified;

  SitterProfile({
    this.experience = '',
    this.bio = '',
    this.rate = 0.0,
    this.verified = false,
  });

  factory SitterProfile.fromJson(Map<String, dynamic> json) {
    return SitterProfile(
      experience: json['experience'] ?? '',
      bio: json['bio'] ?? '',
      rate: (json['rate'] ?? 0.0).toDouble(),
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'bio': bio,
      'rate': rate,
      'verified': verified,
    };
  }
}
