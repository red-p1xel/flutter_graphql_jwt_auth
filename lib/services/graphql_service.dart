import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql/client.dart';

import '../gql/mutations.dart' as mutations;
import '../gql/queries.dart' as queries;

class GraphQLService {
  final storage = new FlutterSecureStorage();
  GraphQLClient _client;

  GraphQLService() {
    HttpLink httpLink = HttpLink(
      uri: 'http://10.0.2.2:8000/graphql/',
    );
    Link _link;

    final AuthLink authLink = AuthLink(
        getToken: () async =>
            'Bearer ${await storage.read(key: 'token') ?? ""}');

    _link = authLink.concat(httpLink as Link);
    _client = GraphQLClient(link: _link, cache: InMemoryCache());
  }

  Future<QueryResult> performQuery(String query,
      {Map<String, dynamic> variables}) async {
    QueryOptions options =
        QueryOptions(documentNode: gql(query), variables: variables);

    final result = await _client.query(options);

    return result;
  }

  Future<QueryResult> performMutation(String query,
      {Map<String, dynamic> variables}) async {
    MutationOptions options =
        MutationOptions(documentNode: gql(query), variables: variables);

    final result = await _client.mutate(options);

    print(result);

    return result;
  }

  Future<QueryResult> signUpMutation(
      String email, String username, String password) async {
    final MutationOptions _options = MutationOptions(
      documentNode: gql(mutations.signUp),
      variables: <String, String>{
        'email': email,
        'name': username,
        'password': password,
      },
    );
    final result = await _client.mutate(_options);
    return result;
  }

  Future<QueryResult> signInQuery({Map<String, dynamic> variables}) async {
    QueryOptions options =
        QueryOptions(documentNode: gql(queries.signIn), variables: variables);
    final result = await _client.query(options);
    return result;
  }

  Future<QueryResult> getUserById(String id) async {
    QueryOptions options = QueryOptions(
      documentNode: gql(queries.getUserById),
      variables: {
        'id': id,
      },
    );
    final result = await _client.query(options);
    return result;
  }

  Future<QueryResult> refreshToken() async {
    QueryOptions options = QueryOptions(
      documentNode: gql(queries.refreshToken),
      variables: {},
    );
    final result = await _client.query(options);
    return result;
  }

  Future<QueryResult> logOut() async {
    QueryOptions options = QueryOptions(
      documentNode: gql(queries.signOut),
      variables: {},
    );
    final result = await _client.query(options);
    return result;
  }
}
