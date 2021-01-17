const String signIn = r'''
  query SignIn($email: String!, $password: String!) {
    signIn(email: $email, password: $password)
  }
''';

const String getUserById = r'''
  query User($id: String!) {
    user(id: $id) {
      id
      email
      name
      profile {
        id
        fileName
        filePath
        createdAt
        updatedAt
      }
      settings {
        id
        title
        description
        data
      }
      updatedAt
    }
  }
''';

const String refreshToken = r'''
  query RefreshToken() {
    refreshToken()
  }
''';

const String signOut = r'''
  query SignOut() {
    signOut()
  }
''';
