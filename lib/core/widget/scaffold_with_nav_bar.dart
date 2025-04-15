import 'package:android_tools/core/device_list/device_list_cubit.dart';
import 'package:android_tools/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  late SidebarXController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = SidebarXController(
      selectedIndex: widget.navigationShell.currentIndex,
    );
    // Update controller when branch changes
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarX(
            controller: _sidebarController,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: canvasColor,
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(color: Colors.black),
              selectedTextStyle: const TextStyle(color: actionColor),
              itemTextPadding: const EdgeInsets.only(left: 10),
              selectedItemTextPadding: const EdgeInsets.only(left: 10),
              itemDecoration: BoxDecoration(
                border: Border.all(color: canvasColor),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: actionColor.withOpacity(0.37),
                ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.grey,
                size: 20,
              ),
              hoverTextStyle: const TextStyle(
                color: actionColor,
              ),
              hoverIconTheme: const IconThemeData(
                color: actionColor,
                size: 20,
              ),
            ),
            extendedTheme: const SidebarXTheme(
              width: 130,
              decoration: BoxDecoration(
                color: canvasColor,
              ),
              margin: EdgeInsets.only(right: 10),
            ),
            footerDivider: divider,
            headerBuilder: (context, extended) {
              return SizedBox(
                height: 20,
                // child: Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Image.asset('assets/images/avatar.png'),
                // ),
              );
            },
            items: [
              SidebarXItem(
                icon: Icons.home,
                label: 'Home',
                onTap: () {
                  widget.navigationShell.goBranch(0); // Home branch
                },
              ),
              SidebarXItem(
                icon: Icons.backup,
                label: 'Back up',
                onTap: () {
                  widget.navigationShell.goBranch(1); // Backup branch
                },
              ),
            ],
          ),
          Divider(
            height: double.infinity,
            thickness: 1,
            color: Colors.grey,
          ),
          BlocProvider<DeviceListCubit>(
            create: (context) => sl()..init(),
            child: Expanded(child: widget.navigationShell)
          ),
        ],
      ),
    );
  }
}

const primaryColor = Colors.black;
const canvasColor = Colors.white;
const scaffoldBackgroundColor = Colors.black;
const accentCanvasColor = Colors.black;
const white = Colors.white;
const actionColor = Color(0xFF5F5FA7);

final divider = Divider(color: white.withOpacity(0.3), height: 1);
