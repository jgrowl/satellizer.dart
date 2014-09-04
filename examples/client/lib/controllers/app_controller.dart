library app_controller;

import 'package:angular/angular.dart';

@Controller(
    selector: '[app]',
    publishAs: 'appCtrl')
class AppController {
  final Router _router;

  AppController(this._router);
}

