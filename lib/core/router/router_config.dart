import 'package:android_tools/core/router/route_name.dart';
import 'package:android_tools/features/home/presentation/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteName.HOME,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    _buildRouteWithDefaultTransition(
      path: "/",
      pageBuilder: (context, state) => const HomeScreen(),
    ),
    _buildRouteWithDefaultTransition(
      path: RouteName.HOME,
      pageBuilder: (context, state) => const HomeScreen(),
    ),
  ]
);

GoRoute _buildRouteWithDefaultTransition({
  required String path,
  String? name,
  GlobalKey<NavigatorState>? parentNavigatorKey,
  GoRouterRedirect? redirect,
  List<RouteBase>? routes,
  required Widget Function(BuildContext, GoRouterState) pageBuilder,
}) {
  return GoRoute(
    path: path,
    name: name,
    routes: routes ?? [],
    parentNavigatorKey: parentNavigatorKey,
    redirect: redirect,
    pageBuilder:
        (context, state) =>
        CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 300),
          child: pageBuilder(context, state),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: ScaleTransition(
                scale: animation.drive(
                  Tween<double>(
                    begin: 0.95,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeOutBack)),
                ),
                child: child,
              ),
            );
          },
        ),
  );
}
