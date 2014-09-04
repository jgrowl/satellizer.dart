library satellizer.auth_service;

import 'dart:js';
import 'dart:async';
import 'dart:html';
import 'dart:convert' show JSON;

import 'package:angular/angular.dart';

import 'package:satellizer/user.dart';
import 'package:angular_oauthio_wrapper/angular_oauthio_wrapper.dart';

@Injectable()
class AuthConfig {
  String base;        // ie. http://localhost:3000
  String createPath;  // ie. /users.json
  String profilePath; // ie. /users/profile.json
  String apiPrefix;   // ie. /api/v1

  String createUserUrl() {
    return "${base}${createPath}";
  }

  String profileUrl() {
    return "${base}${apiPrefix}${profilePath}";
  }
}

abstract class ProvidersService {
  Future popup(String provider);
}

@Injectable()
class AuthService {
  AuthConfig _authConfig;
  RootScope _rootScope;
  ProvidersService _providersService;
  Storage storage = window.sessionStorage;
  Http _http;
  User currentUser;

  AuthService(this._rootScope, this._providersService, this._http, this._authConfig) {
    currentUser = new User();
    _rootScope.context['currentUser'] = currentUser;
  }

  bool isLoggedIn() {
    return currentUser.isLoggedIn();
  }

  Future authenticate(String provider) {
    return _providersService.popup(provider)
    .then((result) {
      var decode = JSON.decode(result);
      currentUser.username = decode['user']['nickname'];
      currentUser.isServerGeneratedPassword = true;
      return login(decode['user'])
      .then((result) => new Future<dynamic>.value(decode));
    });
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

  Future attemptRestore() {
    if (!isLoggedIn() && canRestoreUser()) {
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

  Future logout() {
    storage.remove('jwt');
    storage.remove('userId');
    currentUser.logout();
    return new Future.value(true);
  }
}

class AuthModule extends Module {
  AuthModule() {
    bind(ProvidersService, toImplementation: OauthioService);
//    bind(OauthioService);
  }
}
