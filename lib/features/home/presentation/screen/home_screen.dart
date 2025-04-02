import 'dart:math';

import 'package:android_tools/core/constant/location_mapping.dart';
import 'package:android_tools/core/constant/time_zone.dart';
import 'package:android_tools/core/router/route_name.dart';
import 'package:android_tools/core/sub_window/sub_window.dart';
import 'package:android_tools/core/util/sub_window_util.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<HomeCubit>(
        create: (context) => sl()..init(),
        child: HomeView(child: widget.child),
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
  String? selectedTimeZone;
  late final TextEditingController _ipController;
  late final TextEditingController _commandController;
  late final TextEditingController _repeatController;
  late final TextEditingController _geoController;
  late final TabController _tabController;
  final tabs = <Widget>[
    Tab(text: "Logs"),
    Tab(text: "Change info"),
    Tab(text: "Backup (RSS)"),
  ];

  @override
  void initState() {
    _repeatController = TextEditingController();
    _commandController = TextEditingController();
    _geoController = TextEditingController();
    _ipController = TextEditingController();
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _commandController.dispose();
    _geoController.dispose();
    _repeatController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                          (search) =>
                              context.read<HomeCubit>().filterCommand(search),
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
                      var hasSelectDevice = state.devices.firstWhereOrNull(
                        (device) => device.isSelected,
                      );
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
                            .read<HomeCubit>()
                            .getValueInsideParentheses(_commandController.text);
                        if (scriptName == null || scriptName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Add script Name")),
                          );
                        }
                        if (!(await context.read<HomeCubit>().scriptExists(
                          scriptName!,
                        ))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Cannot find script $scriptName!"),
                            ),
                          );
                        }
                      }

                      var adbCommand = await context
                          .read<HomeCubit>()
                          .parseCommand(command);
                      if (adbCommand.isLeft) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(adbCommand.left)),
                        );
                        return;
                      }
                      context
                          .read<HomeCubit>()
                          .executeCommandForSelectedDevices(
                            command: adbCommand.right,
                          );
                    },
                    child: Text("Run"),
                  ),
                  Gap(5),
                  ElevatedButton(
                    onPressed:
                        state.isConnectingAll
                            ? null
                            : () {
                              context.read<HomeCubit>().connectAll();
                            },
                    child: Text("Connect All"),
                  ),
                  Gap(5),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.green),
                    onPressed:
                        state.isRefreshing
                            ? null
                            : () async {
                              context.read<HomeCubit>().refresh();
                            },
                    onLongPress: null,
                  ),
                  Gap(2),
                  IconButton(
                    icon: Icon(Icons.phone_android, color: Colors.green),
                    onPressed: () async {
                      var hasSelectDevice = state.devices.firstWhereOrNull(
                        (device) => device.isSelected,
                      );
                      if (hasSelectDevice == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least 1 device"),
                          ),
                        );
                        return;
                      }
                      context.read<HomeCubit>().showScreen();
                    },
                    onLongPress: null,
                  ),
                  Gap(2),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      var hasSelectDevice = state.devices.firstWhereOrNull(
                        (device) => device.isSelected,
                      );
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
                          context.read<HomeCubit>().deleteDevices();
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
                          .read<HomeCubit>()
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
                          .read<HomeCubit>()
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
                          .read<HomeCubit>()
                          .executeCommandForSelectedDevices(
                            command: KeyCommand("KEYCODE_APP_SWITCH"),
                          );
                    },
                  ),
                  Gap(2),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text('Select Geo', style: TextStyle(fontSize: 14)),
                      items: buildTimezoneList(),
                      value: selectedTimeZone,
                      onChanged: (value) {
                        setState(() {
                          selectedTimeZone = value;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 200,
                      ),
                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200,
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 40),
                      dropdownSearchData: DropdownSearchData(
                        searchController: _geoController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: _geoController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Search for an item...',
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return item.value.toString().contains(searchValue);
                        },
                      ),
                      //This to clear the search value when you close the menu
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          _geoController.clear();
                        }
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (selectedTimeZone == null ||
                          selectedTimeZone!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select 1 timezone"),
                          ),
                        );
                        return;
                      }
                      var location =
                          timezoneCoordinates[selectedTimeZone]?[Random()
                              .nextInt(2)];
                      if (location == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cannot find location")),
                        );
                        return;
                      }

                      var hasSelectDevice = state.devices.firstWhereOrNull(
                        (device) => device.isSelected,
                      );
                      if (hasSelectDevice == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least 1 device"),
                          ),
                        );
                        return;
                      }

                      // await context.read<HomeCubit>().executeCommandForSelectedDevices(
                      //   command: ChangeTimeZoneCommand(
                      //     timeZone: timezoneMap[selectedTimeZone]!,
                      //   ),
                      // );
                      // await context.read<HomeCubit>().executeCommandForSelectedDevices(
                      //   command: SetMockLocationCommand(
                      //     latitude: location['lon']!,
                      //     longitude: location['lat']!,
                      //   ),
                      // );

                      await context
                          .read<HomeCubit>()
                          .executeCommandForSelectedDevices(
                            command: ChangeGeoCommand(
                              latitude: location['lat']!,
                              longitude: location['lon']!,
                              timeZone: timezoneMap[selectedTimeZone]!,
                            ),
                          );
                    },
                    child: Text("Change Geo"),
                  ),
                ],
              ),

              Expanded(
                child: ResizableColumns(
                  orientation: ResizableOrientation.horizontal,
                  dividerColor: Colors.black26,
                  dividerThickness: 4.0,
                  initialProportions: const [1, 1],
                  minChildSize: 200.0,
                  children: [
                    (context) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: DataTable2(
                              dataRowHeight: 70,
                              minWidth: 1000,
                              isHorizontalScrollBarVisible: true,
                              onSelectAll: (bool? isSelectAll) {
                                context.read<HomeCubit>().onSelectAll(
                                  isSelectAll,
                                );
                              },

                              headingCheckboxTheme: const CheckboxThemeData(
                                side: BorderSide(width: 2.0),
                              ),
                              columns: const [
                                DataColumn(label: Text('IP')),
                                DataColumn2(
                                  label: Text('Connection Status'),
                                  size: ColumnSize.L,
                                ),
                                DataColumn(label: Text('Geo')),
                                DataColumn2(
                                  label: Text('Command Status'),
                                  size: ColumnSize.L,
                                  fixedWidth: 350,
                                ),
                                DataColumn2(
                                  label: Text('Actions'),
                                  size: ColumnSize.M,
                                ),
                                // New column for actions
                              ],
                              rows:
                                  state.devices
                                      .map(
                                        (device) => DataRow2(
                                          onDoubleTap: () {
                                            debugPrint(
                                              "device.status${device.status}",
                                            );
                                            debugPrint(
                                              "DeviceStatus.fastboot ${DeviceStatus.fastboot}",
                                            );
                                            if (device.status !=
                                                    DeviceStatus.connected &&
                                                device.status !=
                                                    DeviceStatus.fastboot) {
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
                                              subWindow: SubWindow.phoneDetails(
                                                device: device,
                                              ),
                                              title: device.ip,
                                            );
                                          },
                                          selected: device.isSelected,
                                          onSelectChanged: (bool? selected) {
                                            context
                                                .read<HomeCubit>()
                                                .onToggleDeviceSelection(
                                                  device.ip,
                                                  selected ?? false,
                                                );
                                          },
                                          cells: [
                                            DataCell(Text(device.ip)),
                                            DataCell(Text(device.status ?? "")),
                                            DataCell(
                                              Text(
                                                (device.geo != null &&
                                                        device.geo!.isNotEmpty)
                                                    ? timezoneMap.entries
                                                        .firstWhere(
                                                          (entry) =>
                                                              entry.value ==
                                                              device.geo,
                                                          orElse:
                                                              () => MapEntry(
                                                                "",
                                                                "",
                                                              ), // Default case if not found
                                                        )
                                                        .key
                                                    : "",
                                              ),
                                            ),
                                            DataCell(
                                              SingleChildScrollView(
                                                child: Text(
                                                  device.commandStatus ?? "",
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed: () {
                                                      // Handle edit action
                                                      // context.read<HomeCubit>().editDevice(device);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ), // New DataCell for actions
                                          ],
                                        ),
                                      )
                                      .toList(),
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
                                    state.isAddingDevice
                                        ? null
                                        : () async {
                                          String value =
                                              _ipController.text.trim();
                                          if (value.isEmpty) {
                                            return;
                                          }
                                          if (await context
                                              .read<HomeCubit>()
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
                                              .read<HomeCubit>()
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
                    // VerticalDivider(color: Colors.black12, thickness: 2),
                    (context) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TabBar(
                              controller: _tabController,
                              onTap: (int? index) {
                                if (index == null) {
                                  return;
                                }
                                String path = "";
                                switch (index) {
                                  case 0:
                                    path =
                                        "${RouteName.HOME}${RouteName.HOME_LOGS}";
                                    break;
                                  case 1:
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
                              tabs: tabs,
                            ),
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DropdownMenuItem<String>> buildTimezoneList() {
    return timezoneMap.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(
          entry.key,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }
}
