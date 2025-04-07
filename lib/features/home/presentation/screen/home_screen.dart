import 'package:android_tools/core/constant/time_zone.dart';
import 'package:android_tools/core/device_list/adb_device.dart';
import 'package:android_tools/core/device_list/device_list_cubit.dart';
import 'package:android_tools/core/router/route_name.dart';
import 'package:android_tools/core/sub_window/sub_window.dart';
import 'package:android_tools/core/util/sub_window_util.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/domain/entity/device_info.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/features/home/presentation/widget/logs.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:collection/collection.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:resizable_columns/resizable_columns.dart';
import '../../../../injection_container.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => sl<HomeCubit>()),
          BlocProvider(create: (context) => sl<DeviceListCubit>()..init()),
        ],
        child: HomeView(child: child),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  final Widget child;

  const HomeView({super.key, required this.child});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ipController;
  late final TextEditingController _commandController;
  late final TextEditingController _repeatController;
  late final TabController _tabController;
  final tabs = <Widget>[
    Tab(text: "Control"),
    Tab(text: "Install Apps"),
    Tab(text: "Change info"),
    Tab(text: "Backup (RSS)"),
  ];

  @override
  void initState() {
    _repeatController = TextEditingController();
    _commandController = TextEditingController();
    _ipController = TextEditingController();
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _commandController.dispose();
    _repeatController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (homeContext, homeState) {},
      builder: (homeContext, homeState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _repeatController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Repeat',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow((RegExp("[-.0-9]"))),
                      ],
                    ),
                  ),
                  Gap(5),
                  Expanded(
                    child: TypeAheadField<String>(
                      hideOnEmpty: true,
                      controller: _commandController,
                      suggestionsCallback:
                          (search) => context
                              .read<DeviceListCubit>()
                              .filterCommand(search),
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          // autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Command',
                          ),
                        );
                      },
                      itemBuilder: (context, cmd) {
                        return ListTile(title: Text(cmd));
                      },
                      onSelected: (cmd) {
                        _commandController.text = cmd;
                      },
                    ),
                  ),
                  Gap(5),
                  ElevatedButton(
                    onPressed: () async {
                      var command = _commandController.text.trim();
                      var repeatTimesString = _repeatController.text;
                      if (repeatTimesString.isNotEmpty &&
                          (int.tryParse(repeatTimesString) == null ||
                              int.tryParse(repeatTimesString) == 0)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Enter valid repeat time"),
                          ),
                        );
                        return;
                      }
                      var hasSelectDevice = context
                          .read<DeviceListCubit>()
                          .state
                          .devices
                          .firstWhereOrNull((device) => device.isSelected);
                      if (hasSelectDevice == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least 1 device"),
                          ),
                        );
                        return;
                      }
                      if (command.startsWith("RunScript")) {
                        var scriptName = context
                            .read<DeviceListCubit>()
                            .getValueInsideParentheses(_commandController.text);
                        if (scriptName == null || scriptName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Add script Name")),
                          );
                        }
                        if (!(await context
                            .read<DeviceListCubit>()
                            .scriptExists(scriptName!))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Cannot find script $scriptName!"),
                            ),
                          );
                        }
                      }

                      var adbCommand = await context
                          .read<DeviceListCubit>()
                          .parseCommand(command);

                      if (adbCommand.isLeft) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(adbCommand.left)),
                        );
                        return;
                      }

                      context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: adbCommand.right,
                          );
                    },
                    child: Text("Run"),
                  ),
                  Gap(5),
                  ElevatedButton(
                    onPressed:
                        context.read<DeviceListCubit>().state.isConnectingAll
                            ? null
                            : () {
                              context.read<DeviceListCubit>().connectAll();
                            },
                    child: Text("Connect All"),
                  ),
                  Gap(5),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.green),
                    onPressed:
                        context.read<DeviceListCubit>().state.isRefreshing
                            ? null
                            : () async {
                              context.read<DeviceListCubit>().refresh();
                            },
                    onLongPress: null,
                  ),
                  Gap(2),
                  IconButton(
                    icon: Icon(Icons.phone_android, color: Colors.green),
                    onPressed: () async {
                      var hasSelectDevice = context
                          .read<DeviceListCubit>()
                          .state
                          .devices
                          .firstWhereOrNull((device) => device.isSelected);
                      if (hasSelectDevice == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least 1 device"),
                          ),
                        );
                        return;
                      }
                      context.read<DeviceListCubit>().showScreen();
                    },
                    onLongPress: null,
                  ),
                  Gap(2),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      var hasSelectDevice = context
                          .read<DeviceListCubit>()
                          .state
                          .devices
                          .firstWhereOrNull((device) => device.isSelected);
                      if (hasSelectDevice == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least 1 device"),
                          ),
                        );
                        return;
                      }
                      if (await confirm(
                        context,
                        title: const Text('Confirm Delete'),
                        content: const Text('Would you like to remove?'),
                        textOK: const Text('Yes'),
                        textCancel: const Text('No'),
                      )) {
                        if (context.mounted) {
                          context.read<DeviceListCubit>().deleteDevices();
                        }
                      }
                    },
                  ),
                ],
              ),
              Gap(10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: KeyCommand("KEYCODE_BACK"),
                          );
                    },
                  ),
                  Gap(2),
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: KeyCommand("KEYCODE_HOME"),
                          );
                    },
                  ),
                  Gap(2),
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: KeyCommand("KEYCODE_APP_SWITCH"),
                          );
                    },
                  ),
                ],
              ),
              Gap(2),

              Expanded(
                child: ResizableColumns(
                  orientation: ResizableOrientation.horizontal,
                  dividerColor: Colors.black26,
                  dividerThickness: 4.0,
                  initialProportions: const [1, 1, 1],
                  minChildSize: 200.0,
                  children: [
                    (context) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: BlocConsumer<
                              DeviceListCubit,
                              DeviceListState
                            >(
                              listener: (context, state) {},
                              builder: (context, state) {
                                return DataTable2(
                                  dataRowHeight: 70,
                                  minWidth: 1000,
                                  isHorizontalScrollBarVisible: true,
                                  onSelectAll: (bool? isSelectAll) {
                                    context.read<DeviceListCubit>().onSelectAll(
                                      isSelectAll,
                                    );
                                  },

                                  headingCheckboxTheme: const CheckboxThemeData(
                                    side: BorderSide(width: 2.0),
                                  ),
                                  columns: const [
                                    DataColumn2(label: Text('IP')),
                                    DataColumn2(
                                      label: Text('Connection Status'),
                                      size: ColumnSize.M,
                                    ),
                                    DataColumn2(
                                      label: Text('Geo'),
                                      size: ColumnSize.M,
                                    ),
                                    DataColumn2(
                                      label: Text('Spoofed Device Info'),
                                      size: ColumnSize.L,
                                      fixedWidth: 300,
                                    ),
                                    DataColumn2(
                                      label: Text('Command Status'),
                                      size: ColumnSize.L,
                                    ),
                                  ],
                                  rows:
                                      state.devices
                                          .map(
                                            (device) => DataRow2(
                                              onDoubleTap: () {
                                                debugPrint(
                                                  device.status.toString(),
                                                );
                                                if (device.status !=
                                                        DeviceConnectionStatus
                                                            .booted &&
                                                    device.status !=
                                                        DeviceConnectionStatus
                                                            .fastboot &&
                                                    device.status !=
                                                        DeviceConnectionStatus
                                                            .recovery &&
                                                    device.status !=
                                                        DeviceConnectionStatus
                                                            .twrp) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Device is not connected",
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                openSubWindow(
                                                  windowId: device.ip,
                                                  subWindow:
                                                      SubWindow.phoneDetails(
                                                        device: device,
                                                      ),
                                                  title: device.ip,
                                                );
                                              },
                                              selected: device.isSelected,
                                              onSelectChanged: (
                                                bool? selected,
                                              ) {
                                                context
                                                    .read<DeviceListCubit>()
                                                    .onToggleDeviceSelection(
                                                      device.ip,
                                                      selected ?? false,
                                                    );
                                              },
                                              cells: [
                                                DataCell(Text(device.ip)),
                                                DataCell(
                                                  Text(
                                                    device.status ==
                                                            DeviceConnectionStatus
                                                                .booted
                                                        ? "Booted"
                                                        : device.status ==
                                                            DeviceConnectionStatus
                                                                .fastboot
                                                        ? "Fastboot"
                                                        : device.status ==
                                                            DeviceConnectionStatus
                                                                .recovery
                                                        ? "Recovery"
                                                        : device.status ==
                                                            DeviceConnectionStatus
                                                                .twrp
                                                        ? "TWRP"
                                                        : device.status ==
                                                            DeviceConnectionStatus
                                                                .sideload
                                                        ? "Sideload"
                                                        : "Not connected",
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    (device.geo != null &&
                                                            device
                                                                .geo!
                                                                .isNotEmpty)
                                                        ? device.geo!
                                                        : "",
                                                  ),
                                                ),
                                                DataCell(
                                                  SingleChildScrollView(
                                                    child: Text(
                                                      device.spoofedDeviceInfo
                                                              ?.customToString() ??
                                                          "",
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SingleChildScrollView(
                                                    child: Text(
                                                      device.commandStatus ??
                                                          "",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                );
                              },
                            ),
                          ),
                          Gap(15),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _ipController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Device Serial Number',
                                  ),
                                ),
                              ),
                              Gap(5),
                              ElevatedButton(
                                onPressed:
                                    context
                                            .read<DeviceListCubit>()
                                            .state
                                            .isAddingDevice
                                        ? null
                                        : () async {
                                          String value =
                                              _ipController.text.trim();
                                          if (value.isEmpty) {
                                            return;
                                          }
                                          if (await context
                                              .read<DeviceListCubit>()
                                              .deviceExistsBySerial(value)) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Device already exists",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          var result = await context
                                              .read<DeviceListCubit>()
                                              .addDevice(value);
                                          if (result.success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Add Device Successfully",
                                                ),
                                              ),
                                            );
                                            _ipController.text = "";
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "${result.error}: ${result.message}",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                child: Text("Add Device"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    (context) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            onTap: (int? index) {
                              if (index == null) {
                                return;
                              }
                              String path = "";
                              switch (index) {
                                case 0:
                                  path =
                                      "${RouteName.HOME}${RouteName.HOME_CONTROL}";
                                  break;
                                case 1:
                                  path =
                                      "${RouteName.HOME}${RouteName.HOME_INSTALL_APK}";
                                  break;
                                case 2:
                                  path =
                                      "${RouteName.HOME}${RouteName.HOME_CHANGE_INFO}";
                                  break;
                                default:
                                  path =
                                      "${RouteName.HOME}${RouteName.HOME_BACKUP}";
                                  break;
                              }
                              context.push(path);
                            },
                            tabAlignment: TabAlignment.start,
                            tabs: tabs,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(0),
                              child: widget.child,
                            ),
                          ),
                        ],
                      ),
                    ),
                    (context) => Logs(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
