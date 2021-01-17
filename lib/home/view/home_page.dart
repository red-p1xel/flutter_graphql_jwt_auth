import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_jwt_auth/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Builder(
              builder: (context) {
                return Text('''
                    UUID ${user.id}
                    EMAIL: ${user.email} 
                    NAME: ${user.name} 
                    TOKEN: ${user.token}
                  ''');
              },
            ),
            RaisedButton(
              child: const Text('Logout'),
              onPressed: () {
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationLogoutRequested());
              },
            ),
            RaisedButton(
              child: const Text('Refresh Token'),
              onPressed: () {
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationRefreshTokenRequest());
              },
            ),
          ],
        ),
      ),
    );
  }
}
