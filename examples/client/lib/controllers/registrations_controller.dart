library registrations_controller;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'dart:js';
import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';

import 'package:exportable/exportable.dart';

import 'package:web/routes/auth_routes.dart' show authRouteInitializer;
import 'package:satellizer/satellizer.dart';

class SignupForm extends Object with Exportable {
  @export String username;
  @export String email;
  @export String password;

  SignupForm(this.username, this.email, this.password) {}
}

@Controller(
    selector: '[registrations]',
    publishAs: 'registrationsCtrl')
class RegistrationsController {
  final RootScope _rootScope;
  final Router _router;
  final AuthService _authService;
  final NgForm _form;
  User currentUser;

  String username;
  String email;
  String password;

  RegistrationsController(this._rootScope, this._router, this._authService, this._form) {
    currentUser = _authService.currentUser;
    username = currentUser.username;
    email = currentUser.email;
  }

  void create() {
    SignupForm signupForm = new SignupForm(username, email, password);
    _authService.create(signupForm.toMap())
    .then((result) => handleCreate(result))
    .catchError((error) {
      print('therewasanerror');
      print(error);
    });
  }

  Future handleCreate(result) {
    if (result['status'] == 'registered') {
      _router.go('root', {
      });
    }

    return result;
  }
}

