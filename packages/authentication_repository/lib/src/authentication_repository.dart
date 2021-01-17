import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_jwt_auth/services/graphql_service.dart';
import 'package:graphql_jwt_auth/utils/services/jwt_decoder.dart';
import 'package:meta/meta.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final storage = new FlutterSecureStorage();
  final graphQLService = GraphQLService();
  final _controller = StreamController<AuthenticationStatus>();
  String token;

  Stream<AuthenticationStatus> get status async* {
    this.token = await storage.read(key: 'token');
    if (this.token != null) {
      if (JwtDecoder.isExpired(this.token)) {
        this.deleteToken();
        yield AuthenticationStatus.unauthenticated;
        yield* _controller.stream;
      } else {
        var exp = JwtDecoder.getExpirationDate(this.token);
        var now = DateTime.now();
        print('Preview Dates:  exp = $exp  now = $now');
        Duration difference = exp.difference(now);
        print('Difference now with exp is ${difference.inMinutes} minutes');
        print('Set timer to ${difference.inMinutes - 5} for tocken refresh');
        Timer.periodic(Duration(minutes: difference.inMinutes - 5), (timer) {
          final nowDT = DateTime.now();
          print('''
            +-------------------------------------------------------------------
            | Preview token expiration before refresh:
            +-------------------------------------------------------------------
            | [-] current datetime: $nowDT
            | [-] token expired at: $exp
            | [-] token: ${this.token}
            +-------------------------------------------------------------------
          ''');
          this.refreshToken();
        });
        yield AuthenticationStatus.authenticated;
        yield* _controller.stream;
      }
    } else {
      yield AuthenticationStatus.unauthenticated;
      yield* _controller.stream;
    }
  }

  Future<void> signUp({
    @required String email,
    @required String username,
    @required String password,
  }) async {
    assert(email != null && username != null && password != null);
    try {
      await graphQLService.signUpMutation(email, username, password);
    } on Exception {
      throw SignUpFailure();
    }
  }

  Future<String> signIn({
    @required Map<String, dynamic> variables,
  }) async {
    assert(variables != null);
    final result = await graphQLService.signInQuery(variables: variables);
    if (result.hasException) {
      print('graphQLErrors: ${result.exception.graphqlErrors.toString()}');
      print('clientErrors: ${result.exception.clientException.toString()}');
      _controller.add(AuthenticationStatus.unauthenticated);
    } else {
      this.token = result.data['signIn'][0].toString();
      this.persistToken(this.token);
      _controller.add(AuthenticationStatus.authenticated);
    }
    return this.token;
  }

  void logOut() async {
    final result = await graphQLService.logOut();
    if (result.hasException) {
      print('graphQLErrors: ${result.exception.graphqlErrors.toString()}');
      print('clientErrors: ${result.exception.clientException.toString()}');
      _controller.add(AuthenticationStatus.unauthenticated);
    } else {
      this.deleteToken();
      _controller.add(AuthenticationStatus.unauthenticated);
    }
  }

  Future<void> refreshToken() async {
    print('>>>>>>>>>> Renewal token proccess <<<<<<<<<<');
    if (JwtDecoder.isExpired(this.token)) {
      this.deleteToken();
      _controller.add(AuthenticationStatus.unauthenticated);
      print('Current token is expired! User must sign-in again!');
    } else {
      print('Current token is valid! Init refreshToken operation.');
      final result = await graphQLService.refreshToken();
      if (result.hasException) {
        print('GraphQL Errors: ${result.exception.graphqlErrors.toString()}');
        print('Client Errors: ${result.exception.clientException.toString()}');
        _controller.add(AuthenticationStatus.unauthenticated);
      } else {
        print('Token refreshed!');
        final String refreshedToken = result.data['refreshToken'][0].toString();
        this.persistToken(refreshedToken);
        print('Token successfully persisted to secure storage...');
        return refreshedToken;
      }
    }
  }

  Future<void> persistData(dynamic data) async {
    assert(data != null);
    await storage.write(key: 'data', value: data);
  }

  Future<void> persistToken(String token) async {
    assert(token != null);
    await storage.write(key: 'token', value: token);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'token');
  }

  void dispose() => _controller.close();
}

// Exceptions
class SignUpFailure implements Exception {}
