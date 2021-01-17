const String signUp = r'''
  mutation SignUp($name: String!, $email: String!, $password: String!) {
      registerUser(name: $name, email: $email, password: $password) {
        id
        email
        name
    }
  }
''';

const String addStar = r'''
  mutation AddStar($starrableId: ID!) {
    action: addStar(input: {starrableId: $starrableId}) {
      starrable {
        viewerHasStarred
      }
    }
  }
''';
