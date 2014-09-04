library satellizer.user;

import 'package:satellizer/provider.dart';

class User {

  String id;
  String username;
  String email;
  String jwt;
  bool isServerGeneratedPassword;
  List<Provider> providers = new List<Provider>();

  bool isLoggedIn() {
    return id != null && jwt != null;
  }

  void login(Map user) {
    if (user['id'] != null) {
      id = user['id'];
    }
    if (user['username'] != null) {
      username = user['username'];
    }
    if (user['email'] != null) {
      email = user['email'];
    }

    jwt = user['jwt'];

    if (user.containsKey('identities')) {
      providers = user['identities'].map((x) => new Provider(x['provider'], x['uid']));
    }
  }

  void logout() {
    username = null;
    email = null;
    jwt = null;
    id = null;
  }

  bool hasProvider(String provider) {
    return !providers.where((x) => provider == x.provider).isEmpty;
  }

}