library satellizer.auth;

import 'dart:async';
import 'dart:html';
import 'dart:convert' show JSON;

import 'package:angular/angular.dart';

import 'package:satellizer/user.dart';
import 'package:angular_oauthio_wrapper/angular_oauthio_wrapper.dart';

@Injectable()
class AuthConfig {
  String base,        // ie. http://localhost:3000
  createPath,  // ie. /users.json
  profilePath, // ie. /users/profile.json
  apiPrefix;   // ie. /api/v1

//  String logoutRedirect = '/',
//  loginRedirect = '/',
//  signupRedirect = '/login',
//  loginUrl = '/auth/login',
//  signupUrl = '/auth/signup',
//  loginRoute = '/login',
//  signupRoute = '/signup',
//  tokenName = 'token',
//  tokenPrefix = 'satellizer',
//  unlinkUrl = '/auth/unlink/';
//  bool loginOnSignup = true;


  String createUserUrl() {
    return "${base}${createPath}";
  }

  String profileUrl() {
    return "${base}${apiPrefix}${profilePath}";
  }
}

abstract class Providers {
  Future popup(String provider);
}

@Injectable()
class OauthioProvider extends OauthioService with Providers {
  OauthioProvider(OauthioConfig _config) : super(_config) {}
}

@Injectable()
class Auth {
  RootScope _rootScope;
  Storage storage = window.sessionStorage;
  Http _http;
  AuthConfig _authConfig;
  Providers _providers;
  User currentUser;

  Auth(this._rootScope, this._providers, this._http, this._authConfig) {
    currentUser = new User();
    _rootScope.context['currentUser'] = currentUser;
  }

  Future login(user) {
    if (user.containsKey('jwt')) {
      storage['jwt'] = user['jwt'];
    }

    if (user.containsKey('id')) {
      storage['userId'] = user['id'].toString();
    }

    currentUser.login(user);

    return new Future<dynamic>.value(user);
  }

  Future signup(User user) {

  }

  Future authenticate(String provider) {
    return _providers.popup(provider)
    .then((result) {
      var decode = JSON.decode(result);
      currentUser.username = decode['user']['nickname'];
      currentUser.isServerGeneratedPassword = true;
      return login(decode['user'])
      .then((result) => new Future<dynamic>.value(decode));
    });
  }

  Future logout() {
    storage.remove('jwt');
    storage.remove('userId');
    currentUser.logout();
    return new Future.value(true);
  }

  bool isAuthenticated() {
    return currentUser.isLoggedIn();
  }

  Future link() {

  }

  Future unlink() {

  }

  // After this point is custom stuff

  Future attemptRestore() {
    if (!isAuthenticated() && canRestoreUser()) {
      return profile().then((result) => currentUser.login(result['user']));
    }

    return new Future.value(true);
  }

  bool canRestoreUser() {
    return storage.containsKey('userId') && storage.containsKey('jwt');
  }

  Future profile() {
    return _http.get(_authConfig.profileUrl(), withCredentials: true).then((response){
      return response.data;
    });
  }

  Future create(Map<String, String> user) {
    return _http.post(_authConfig.createUserUrl(), {'user': user}, withCredentials: true).then((response){
      var user = response.data['user'];
      return login(user).then((r) =>new Future<dynamic>.value({'status': 'registered', 'user': user}));
    });
  }
}

class AuthModule extends Module {
  AuthModule() {
    // TODO: Make a non-oauthio ProviderService and make it default
//    bind(Providers, toImplementation: OauthioProvider);
    bind(Providers, toImplementation: OauthioProvider);
  }
}
