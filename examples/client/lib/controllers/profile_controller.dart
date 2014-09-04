library profile_controller;

import 'package:angular/angular.dart';

import 'package:satellizer/satellizer.dart';

@Controller(
    selector: '[profile]',
    publishAs: 'ctrl')
class ProfileController {
  final Router _router;
  final AuthService _authService;
  User currentUser;
  RootScope _rootScope;

  ProfileController(this._router, this._authService, this._rootScope) {
    currentUser = _authService.currentUser;
  }

}

