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

  Stream<AuthenticationStatus> get status async* {
    final String token = await storage.read(key: 'token');
    if (token != null) {
      // TODO: Move JWT validation code block to another method
      if (JwtDecoder.isExpired(token)) {
        // Delete expired token from storage
        this.deleteToken();
        await Future<void>.delayed(const Duration(seconds: 1));
        yield AuthenticationStatus.unauthenticated;
        yield* _controller.stream;
      } else {
        // Token valid, set status `authenticated`
        await Future<void>.delayed(const Duration(seconds: 1));
        yield AuthenticationStatus.authenticated;
        yield* _controller.stream;
      }
    } else {
      // Token not present, set status `unauthenticated`
      await Future<void>.delayed(const Duration(seconds: 1));
      yield AuthenticationStatus.unauthenticated;
      yield* _controller.stream;
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
      final String token = result.data['signIn'][0].toString();
      this.persistToken(token);
      _controller.add(AuthenticationStatus.authenticated);
      return token;
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

  void logOut() {
    //TODO: Call API method for server-side user logout

    this.deleteToken();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  Future<void> refreshToken() async {
    // TODO: Before send refreshToken request to server need validate jwt token
    // TODO: if is token expired ... recommend signIn...
    final result = await graphQLService.refreshToken();
    //TODO: Move result validation to specified method
    if (result.hasException) {
      print('graphQLErrors: ${result.exception.graphqlErrors.toString()}');
      print('clientErrors: ${result.exception.clientException.toString()}');
      _controller.add(AuthenticationStatus.unauthenticated);
    } else {
      final String refreshedToken = result.data['refreshToken'][0].toString();
      _controller.add(AuthenticationStatus.authenticated);
      this.persistToken(refreshedToken);
      return refreshedToken;
    }
  }

  void dispose() => _controller.close();
}
