import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String loginCode;
  final String password;
  final String userType;
  final String? schoolCode;

  const AuthLoginRequested({
    required this.loginCode,
    required this.password,
    required this.userType,
    this.schoolCode,
  });

  @override
  List<Object?> get props => [loginCode, password, userType, schoolCode];
}

class AuthLogoutRequested extends AuthEvent {}
