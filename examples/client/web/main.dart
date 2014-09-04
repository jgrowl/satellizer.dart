import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'dart:js';
import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';

import 'package:web/controllers/app_controller.dart';
import 'package:web/controllers/login_controller.dart';
import 'package:web/controllers/profile_controller.dart';
import 'package:web/controllers/registrations_controller.dart';
import 'package:web/routes/auth_routes.dart';
import 'package:satellizer/satellizer.dart';
import 'package:angular_oauthio_wrapper/angular_oauthio_wrapper.dart';

class WebModule extends Module {
  WebModule() {
    bind(AuthConfig, toValue: new AuthConfig()
      ..base='http://localhost:3000'
      ..createPath='/users.json'
      ..profilePath='/profile.json'
      ..apiPrefix='/api/v1'
    );
    bind(AuthService);

    String publicKey = 'YOUR_PUBLIC_KEY';
    bind(OauthioConfig, toValue: new OmniauthOauthioConfig(publicKey, 'localhost', 3000, 'users/auth')..secure=false);

    bind(RouteInitializerFn, toImplementation: AuthRouteInitializer);
    bind(AppController);
    bind(LoginController);
    bind(ProfileController);
    bind(RegistrationsController);
    bind(NgRoutingUsePushState,  toValue: new NgRoutingUsePushState.value(false));
  }
}

void main() {
//  Logger.root.level = Level.FINEST;
//  Logger.root.onRecord.listen((LogRecord r) { print(r.message); });

  Injector injector = applicationFactory()
  .addModule(new AuthModule())
  .addModule(new WebModule())
  .run();
}

