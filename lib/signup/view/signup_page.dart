import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_jwt_auth/signup/signup.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SignupPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: BlocProvider<SignupCubit>(
          create: (_) => SignupCubit(context.read<AuthenticationRepository>()),
          child: SignupForm(),
        ),
      ),
    );
  }
}
