import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    this.id,
    this.email,
    this.name,
    this.token,
  });

  final String id;
  final String email;
  final String name;
  final String token;

  @override
  List<Object> get props => [id, email, name, token];

  static const empty = User();
}
