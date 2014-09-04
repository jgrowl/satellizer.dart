library auth;

import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';

import 'package:satellizer/satellizer.dart';


class AuthRouteInitializer {

  AuthService _authService;
  Router _router;
  HttpInterceptors _httpInterceptors;

  AuthRouteInitializer(this._authService, this._httpInterceptors) {
    // define your interceptor
    var intercept = new HttpInterceptor();
    intercept.request = (HttpResponseConfig requestConfig) {
      Storage storage = window.sessionStorage;

      var jwt = storage['jwt'];
      if (jwt != null) {
        requestConfig.headers['Authorization'] = 'Bearer ' + jwt;
      }

      return requestConfig;
    };
    intercept.response = (HttpResponse response) {
      if (response.status == 401) {
        // TODO: handle the case where the user is not authenticated
        print('user not authed');
      }
      return response;
    };
//  intercept.requestError = (dynamic error) => /* something */;
//  intercept.responseError = (dynamic error) => /* something */;
//

    // register/add your interceptor
    _httpInterceptors.add(intercept);
  }

  void call(Router router, RouteViewFactory views) {
    _router = router;
    views.configure({
      'root': authNgRoute(path: '/', view: 'views/home.html', defaultRoute: true),
      'signup': authNgRoute(path: '/users/sign_up', view: 'views/users/sign_up.html'),
      'login': authNgRoute(path: '/login', view: 'views/login.html'),
      'logout': authNgRoute(path: '/logout'),
      'profile': authNgRoute(path: '/users/profile', view: 'views/users/profile.html')
    });
  }

  NgRouteCfg authNgRoute({String path, String view, String viewHtml,
                           Map<String, NgRouteCfg> mount, modules(), bool defaultRoute: false,
                           RoutePreEnterEventHandler preEnter, RouteEnterEventHandler enter,
                           RoutePreLeaveEventHandler preLeave, RouteLeaveEventHandler leave,
                           dontLeaveOnParamChanges: false}) {
    preEnter = RoutePreEnterEventHandlerWrapper(preEnter);
    return new NgRouteCfg(path: path, view: view, viewHtml: viewHtml,
                          mount: mount, modules: modules, defaultRoute: defaultRoute,
                          preEnter: preEnter, preLeave: preLeave, enter: enter, leave: leave,
                          dontLeaveOnParamChanges: dontLeaveOnParamChanges);
  }

    Function RoutePreEnterEventHandlerWrapper(RoutePreEnterEventHandler preEnter) {

    void CustomRoutePreEnterEventHandler(RoutePreEnterEvent event) {

      Future.wait([_authService.attemptRestore()]).then((r) {
        switch (event.route.name) {
          // Some pages should be accessible to everyone
          case 'root':
            break;

          // Some pages should not be accessible to logged in users
          case 'signup':
          case 'login':
            if(_authService.isLoggedIn()) {
              // TODO: Can we go back the previous page?
//              _router.go('root', {}, replace: true);
              _router.go('root', {});
            }
            break;

          // Some Routes need special handling
          case 'logout':
            Future.wait([_authService.logout()]).then((r) {
              _router.go('root', {});
            });
            break;
          // The default case will ensure the user is authenticated and authorized to view resource.
          default:
            if(!_authService.isLoggedIn()) {
              _router.go('login', {});
            }
        }

        if (preEnter != null) {
          preEnter(event);
        }
      });
    }

    return CustomRoutePreEnterEventHandler;
  }
}

