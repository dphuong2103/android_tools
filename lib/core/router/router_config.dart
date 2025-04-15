import 'package:android_tools/core/router/route_name.dart';
import 'package:android_tools/core/widget/scaffold_with_nav_bar.dart';
import 'package:android_tools/features/backup/presentation/screens/backup_screen.dart';
import 'package:android_tools/features/home/presentation/screen/home_screen.dart';
import 'package:android_tools/features/home/presentation/widget/backup_tab.dart';
import 'package:android_tools/features/home/presentation/widget/change_device_info_tab.dart';
import 'package:android_tools/features/home/presentation/widget/control_tab.dart';
import 'package:android_tools/features/home/presentation/widget/install_apk_tab.dart';
import 'package:android_tools/features/login/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '${RouteName.HOME}${RouteName.HOME_CONTROL}', // Updated to "MAIN"
  debugLogDiagnostics: true,
  routes: [
    // Standalone Login Route
    GoRoute(
      path: RouteName.LOGIN,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Tabbed Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // MAIN BRANCH (formerly HOME)
        StatefulShellBranch(
          routes: [
            ShellRoute(
              builder: (context, state, child) {
                return HomeScreen(child: child); // Wraps the sub-tabs
              },
              routes: [
                GoRoute(
                  path: '${RouteName.HOME}${RouteName.HOME_CONTROL}',
                  pageBuilder: (context, state) => NoTransitionPage(child: ControlTab()),
                ),
                GoRoute(
                  path: '${RouteName.HOME}${RouteName.HOME_INSTALL_APK}',
                  pageBuilder: (context, state) => NoTransitionPage(child: InstallApkTab()),
                ),
                GoRoute(
                  path: '${RouteName.HOME}${RouteName.HOME_CHANGE_INFO}',
                  pageBuilder: (context, state) => NoTransitionPage(child: ChangeDeviceInfoTab()),
                ),
                GoRoute(
                  path: '${RouteName.HOME}${RouteName.HOME_BACKUP}',
                  pageBuilder: (context, state) => NoTransitionPage(child: BackupTab()),
                ),
              ],
            ),
          ],
        ),

        // BACKUP BRANCH
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteName.BACK_UP, // e.g., '/backup'
              pageBuilder: (context, state) => NoTransitionPage(child: BackupScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);