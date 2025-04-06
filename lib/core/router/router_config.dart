import 'package:android_tools/core/router/route_name.dart';
import 'package:android_tools/features/home/presentation/screen/home_screen.dart';
import 'package:android_tools/features/home/presentation/widget/backup_tab.dart';
import 'package:android_tools/features/home/presentation/widget/change_device_info_tab.dart';
import 'package:android_tools/features/home/presentation/widget/install_apk_tab.dart';
import 'package:android_tools/features/login/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _homeShelfNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '${RouteName.HOME}${RouteName.HOME_INSTALL_APK}', // Default route
  routes: [
    /// LOGIN ROUTE
    GoRoute(
      path: RouteName.LOGIN,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    /// SHELL ROUTE - Home Screen
    ShellRoute(
      navigatorKey: _homeShelfNavigatorKey,
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
        /// Nested routes inside `HomeScreen`
        GoRoute(
          path: '${RouteName.HOME}${RouteName.HOME_INSTALL_APK}',
          pageBuilder: (context, state) => NoTransitionPage(
            child: InstallApkTab(),
          ),
        ),
        GoRoute(
          path: '${RouteName.HOME}${RouteName.HOME_CHANGE_INFO}',
          pageBuilder: (context, state) => NoTransitionPage(
            child: ChangeDeviceInfoTab(),
          ),
        ),
        GoRoute(
          path: '${RouteName.HOME}${RouteName.HOME_BACKUP}',
          pageBuilder: (context, state) => NoTransitionPage(
            child: BackupTab(),
          ),
        ),
      ],
    ),
  ],
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
        (context, state) => CustomTransitionPage<void>(
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
