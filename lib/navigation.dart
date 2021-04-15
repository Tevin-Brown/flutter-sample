import 'package:biome/screens/home.dart';
import 'package:biome/screens/layout_demo.dart';
import 'package:flutter/material.dart';

class AppRoutePath {
  final int id;
  final bool isUnknown;

  AppRoutePath.home()
      : id = null,
        isUnknown = false;

  AppRoutePath.details(this.id) : isUnknown = false;

  AppRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;
  String _selectedApp;
  List<String> apps = ['Multipage', 'Layout'];
  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  AppRoutePath get currentConfiguration {
    return _selectedApp == null
        ? AppRoutePath.home()
        : AppRoutePath.details(apps.indexOf(_selectedApp));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
            key: ValueKey('AppListPage'),
            child: AppListScreen(apps: apps, onTapped: _handleAppTapped)),
        if (_selectedApp == 'Layout')
          MaterialPage(key: ValueKey(_selectedApp), child: LayoutDemo())
        else if (_selectedApp != null)
          MaterialPage(
              key: ValueKey(_selectedApp),
              child: AppDetailsScreen(appname: _selectedApp))
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedApp to null
        _selectedApp = null;
        notifyListeners();

        return true;
      },
    );
  }

  void _handleAppTapped(String app) {
    _selectedApp = app;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path.isUnknown) {
      _selectedApp = null;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id < 0 || path.id > apps.length - 1) {
        return;
      }

      _selectedApp = apps[path.id];
    } else {
      _selectedApp = null;
    }
  }
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return AppRoutePath.home();
    }

    // Handle '/App/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'app') return AppRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return AppRoutePath.unknown();
      return AppRoutePath.details(id);
    }

    // Handle unknown routes
    return AppRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/app/${path.id}');
    }
    return null;
  }
}
