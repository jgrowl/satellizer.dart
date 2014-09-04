library login_controller;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'dart:js';
import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';

import 'package:satellizer/satellizer.dart';
import 'package:web/routes/auth_routes.dart' show authRouteInitializer;

class LoginForm {

}

@Controller(
    selector: '[login]',
    publishAs: 'ctrl')
class LoginController {
  final Router _router;
  final AuthService _authService;

  LoginForm loginForm;

  LoginController(this._router, this._authService) {}

  void authenticate(String provider) {
    _authService.authenticate(provider)
    .then((result) => login(result))
    .catchError((e) {
      print('therewasanerror');
      print(e);
    });
  }

  void login(result) {
    if(result['status'] == 'additional_info_required') {
      _router.go('signup', {});
    } else if(result['status'] == 'signed_in') {
      _router.go('root', {});
    }
  }

//  void logout() {
//    _authService.logout();
//    _router.go('root', {});
//  }

}

