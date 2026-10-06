import 'package:app_boilerplate/core/network/api_response_parser.dart';
import 'package:app_boilerplate/features/auth/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

/// Response of `POST /users/login`. It can also be wrapped in `data`.
class LoginResponseModel extends Equatable {
  const LoginResponseModel({
    this.message,
    this.token,
    this.refreshToken,
    this.user,
  });

  final String? message;
  final String? token;
  final String? refreshToken;
  final UserModel? user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final unwrapped = ApiResponseParser.unwrapData(json);
    final payload = unwrapped is Map<String, dynamic> ? unwrapped : json;
    final user = payload['user'];

    return LoginResponseModel(
      message: (payload['message'] ?? json['message']) as String?,
      token: (payload['token'] ?? payload['accessToken']) as String?,
      refreshToken: payload['refreshToken'] as String?,
      user: user is Map<String, dynamic> ? UserModel.fromJson(user) : null,
    );
  }

  @override
  List<Object?> get props => [message, token, refreshToken, user];
}
