import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePicUrl,
    this.isVerified = false,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePicUrl;
  final bool isVerified;

  String get fullName {
    final name = [
      firstName,
      lastName,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    return name.isEmpty ? email : name;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    profilePicUrl,
    isVerified,
  ];
}
