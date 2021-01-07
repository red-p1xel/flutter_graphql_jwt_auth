import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_jwt_auth/services/graphql_service.dart';
import 'package:graphql_jwt_auth/utils/services/jwt_decoder.dart';

import 'models/models.dart';

class UserRepository {
  final storage = new FlutterSecureStorage();
  final graphQLService = GraphQLService();

  User _user;

  Future<String> restoreToken() async {
    final String restoredToken = await storage.read(key: 'token');
    return restoredToken;
  }

  Future<User> getUser() async {
    final String token = await storage.read(key: 'token');

    if (token != null) {
      final decoded = JwtDecoder.decode(token);

      print('${decoded['sub']}');

      final result = await graphQLService.getUserById(decoded['sub']);
      if (result == null) {
        return null;
      }
      if (result.hasException) {
        print('graphQLErrors: ${result.exception.graphqlErrors.toString()}');
        print('clientErrors: ${result.exception.clientException.toString()}');
      } else {
        final data = result.data['user'];
        _user = User(
          id: data["id"],
          email: data["email"],
          name: data["name"],
          token: token,
        );
        return _user;
      }
    }
  }
}
