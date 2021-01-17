part of 'signup_cubit.dart';

enum ConfirmPasswordValidationError { invalid }

class SignupState extends Equatable {
  const SignupState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
  });

  final FormzStatus status;
  final Email email;
  final Username username;
  final ConfirmedPassword confirmedPassword;
  final Password password;

  @override
  List<Object> get props => [
        status,
        email,
        username,
        password,
        confirmedPassword,
      ];

  SignupState copyWith({
    FormzStatus status,
    Email email,
    Username username,
    Password password,
    ConfirmedPassword confirmedPassword,
  }) {
    return SignupState(
      status: status ?? this.status,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
    );
  }
}
