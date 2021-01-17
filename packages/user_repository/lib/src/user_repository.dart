import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_jwt_auth/services/graphql_service.dart';
import 'package:graphql_jwt_auth/utils/services/jwt_decoder.dart';

import 'models/models.dart';

class UserRepository {
  final storage = new FlutterSecureStorage();
  final graphQLService = GraphQLService();

  User user;

  // todo: need testing
  StreamController _streamController = StreamController<User>();
  Stream<User> get apiUser => _streamController.stream;

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
        user = User(
          id: data["id"],
          email: data["email"],
          name: data["name"],
          token: token,
        );
        // todo: need testing
        _streamController.add(user);

        return user;
      }
    }
  }
}
