import 'package:android_tools/core/constant/time_zone.dart';
import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/features/home/presentation/widget/log_item.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:collection/collection.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:gap/gap.dart';

import '../../../../injection_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<HomeCubit>(
        create: (context) => sl()..init(),
        child: HomeView(),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? selectedTimeZone;
  var ipController = TextEditingController();
  var commandController = TextEditingController();
  var geoController = TextEditingController();

  @override
  void dispose() {
    ipController.dispose();
    commandController.dispose();
    geoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TypeAheadField<String>(
                            hideOnEmpty: true,
                            controller: commandController,
                            suggestionsCallback:
                                (search) => context
                                    .read<HomeCubit>()
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
                              commandController.text = cmd;
                            },
                          ),
                        ),
                        Gap(5),
                        ElevatedButton(
                          onPressed: () async {
                            var hasSelectDevice = state.devices
                                .firstWhereOrNull(
                                  (device) => device.isSelected,
                                );
                            if (hasSelectDevice == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select at least 1 device",
                                  ),
                                ),
                              );
                              return;
                            }
                            if (commandController.text.startsWith(
                              "RunScript",
                            )) {
                              var scriptName = context
                                  .read<HomeCubit>()
                                  .getValueInsideParentheses(
                                    commandController.text,
                                  );
                              if (scriptName == null || scriptName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Add script Name"),
                                  ),
                                );
                              }
                              if (!(await context
                                  .read<HomeCubit>()
                                  .scriptExists(scriptName!))) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Cannot find script $scriptName!",
                                    ),
                                  ),
                                );
                              }
                            }
                            context.read<HomeCubit>().runCommand(
                              commandController.text,
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
                            var hasSelectDevice = state.devices
                                .firstWhereOrNull(
                                  (device) => device.isSelected,
                                );
                            if (hasSelectDevice == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select at least 1 device",
                                  ),
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
                            var hasSelectDevice = state.devices
                                .firstWhereOrNull(
                                  (device) => device.isSelected,
                                );
                            if (hasSelectDevice == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select at least 1 device",
                                  ),
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
                            context.read<HomeCubit>().runCommand(
                              "KEYCODE_BACK",
                            );
                          },
                        ),
                        Gap(2),
                        IconButton(
                          icon: Icon(Icons.home),
                          onPressed: () {
                            context.read<HomeCubit>().runCommand(
                              "KEYCODE_HOME",
                            );
                          },
                        ),
                        Gap(2),
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            context.read<HomeCubit>().runCommand(
                              "KEYCODE_APP_SWITCH",
                            );
                          },
                        ),
                        Gap(2),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Geo',
                              style: TextStyle(fontSize: 14),
                            ),
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
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                            dropdownSearchData: DropdownSearchData(
                              searchController: geoController,
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
                                  controller: geoController,
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
                                return item.value.toString().contains(
                                  searchValue,
                                );
                              },
                            ),
                            //This to clear the search value when you close the menu
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                geoController.clear();
                              }
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (selectedTimeZone == null || selectedTimeZone!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select 1 timezone",
                                  ),
                                ),
                              );
                              return;
                            }
                            var hasSelectDevice = state.devices
                                .firstWhereOrNull(
                                  (device) => device.isSelected,
                                );
                            if (hasSelectDevice == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select at least 1 device",
                                  ),
                                ),
                              );
                              return;
                            }
                            context.read<HomeCubit>().runCommand("$changeTimezone(${timezoneMap[selectedTimeZone]})");
                          },
                          child: Text("Change Geo"),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: DataTable2(
                              isHorizontalScrollBarVisible: true,
                              onSelectAll: (bool? isSelectAll) {
                                context.read<HomeCubit>().onSelectAll(
                                  isSelectAll,
                                );
                              },
                              headingCheckboxTheme: const CheckboxThemeData(
                                side: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              columns: const [
                                DataColumn(label: Text('IP')),
                                DataColumn(label: Text('Connection Status')),
                                DataColumn(label: Text('Geo')),
                                DataColumn2(
                                  label: Text('Command Status'),
                                  size: ColumnSize.L,
                                ),
                                DataColumn(label: Text('Actions')),
                                // New column for actions
                              ],
                              rows:
                                  state.devices
                                      .map(
                                        (device) => DataRow(
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
                                              Text(device.commandStatus ?? ""),
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
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      // Handle delete action
                                                      // context.read<HomeCubit>().deleteDevice(device.ip);
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
                          Flexible(
                            child: BlocConsumer<LogCubit, LogState>(
                              listener: (context, logState) {},
                              builder: (context, logState) {
                                return ListView.builder(
                                  itemCount: logState.logs.length,
                                  itemBuilder: (context, index) {
                                    return LogItem(log: logState.logs[index]);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: TextField(controller: ipController)),
                          ElevatedButton(
                            onPressed:
                                state.isAddingDevice
                                    ? null
                                    : () async {
                                      String value = ipController.text.trim();
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
                                        ipController.text = "";
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${result.error}: ${result.message ?? ""}",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            child: Text("Add Device"),
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
