import 'package:app_boilerplate/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    super.profilePicUrl,
    super.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // MongoDB returns `_id`.
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePicUrl: json['profilePicUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicUrl': profilePicUrl,
      'isVerified': isVerified,
    };
  }
}
