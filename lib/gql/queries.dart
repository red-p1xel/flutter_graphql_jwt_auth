const String signIn = r'''
  query SignIn($email: String!, $password: String!) {
    signIn(email: $email, password: $password)
  }
''';

const String getUserById = r'''
  query User($id: Int!) {
    user(id: $id) {
      id
      email
      name
      settings {
        id
        title
        description
        data
      }
      updated
    }
  }
''';

const String refreshToken = r'''
  query RefreshToken() {
    refreshToken()
  }
''';
