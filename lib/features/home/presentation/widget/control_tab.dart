import 'dart:math';

import 'package:android_tools/core/constant/location_mapping.dart';
import 'package:android_tools/core/constant/time_zone.dart';
import 'package:android_tools/core/device_list/device_list_cubit.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlTab extends StatefulWidget {
  const ControlTab({super.key});

  @override
  State<ControlTab> createState() => _ControlTabState();
}

Map<BroadCastCommandType, String> broadCastTypesMap = {
  BroadCastCommandType.RemoveAccounts: "Remove Accounts",
};

class _ControlTabState extends State<ControlTab> {
  late final TextEditingController _proxyIpController;
  late final TextEditingController _proxyPortController;
  late final TextEditingController _searchGeoController;
  late final TextEditingController _chPlayUrlController;
  bool _isAlwaysOn = false;
  bool _isWifiOn = true;
  double _brightness = 50;
  int _volume = 7;
  String? _selectedTimeZone;
  ValueNotifier<BroadCastCommandType> broadCastCommand = ValueNotifier(
    BroadCastCommandType.RemoveAccounts,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _proxyIpController = TextEditingController();
    _proxyPortController = TextEditingController();
    _searchGeoController = TextEditingController();
    _chPlayUrlController = TextEditingController();
    _getProxyInfoFromSharedPreferences();
    _getGeoFromSharedPreferences();
    _getChPlayUrlFromSharePreferences();
  }

  @override
  void dispose() {
    super.dispose();
    _proxyIpController.dispose();
    _proxyPortController.dispose();
    _searchGeoController.dispose();
    _chPlayUrlController.dispose();
  }

  Future<void> _getProxyInfoFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final proxyIp = prefs.getString('proxyIp');
    final proxyPort = prefs.getString('proxyPort');
    if (proxyIp != null && proxyIp.isNotEmpty) {
      _proxyIpController.text = proxyIp;
    }
    if (proxyPort != null && proxyPort.isNotEmpty) {
      _proxyPortController.text = proxyPort;
    }
  }

  Future<void> _getGeoFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final geo = prefs.getString('geo');
    if (geo != null && geo.isNotEmpty) {
      setState(() {
        _selectedTimeZone = geo;
      });
    }
  }

  Future<void> _getChPlayUrlFromSharePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('chPlayUrl');
    if (url != null && url.isNotEmpty) {
      setState(() {
        _chPlayUrlController.text = url;
      });
    }
  }


  Widget _buildStateButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          [
                ButtonState(text: "Reboot", command: RebootCommand()),
                ButtonState(text: "Twrp/Recovery", command: RecoveryCommand()),
                ButtonState(text: "Fastboot", command: FastbootCommand()),
                ButtonState(
                  text: "Change info (random)",
                  command: ChangeRandomDeviceInfoCommand(),
                ),
              ]
              .map(
                (buttonState) => OutlinedButton(
                  onPressed: () async {
                    var devices =
                        context.read<DeviceListCubit>().getSelectedDevices();
                    if (devices.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select at least 1 device"),
                        ),
                      );
                      return;
                    }
                    await context
                        .read<DeviceListCubit>()
                        .executeCommandForSelectedDevices(
                          command: buttonState.command,
                        );
                  },
                  child: Text(buttonState.text),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
              ),
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proxyIpController,
                          decoration: InputDecoration(
                            labelText: 'Proxy IP',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      VerticalDivider(color: Colors.black, thickness: 2),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _proxyPortController,
                          decoration: InputDecoration(
                            labelText: 'Port',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_proxyIpController.text.trim().isEmpty ||
                              _proxyPortController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter proxy info"),
                              ),
                            );
                            return;
                          }
                          var devices =
                              context
                                  .read<DeviceListCubit>()
                                  .getSelectedDevices();
                          if (devices.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select at least 1 device",
                                ),
                              ),
                            );
                            return;
                          }
                          // await context
                          //     .read<DeviceListCubit>()
                          //     .executeCommandForSelectedDevices(
                          //   command: SetWifiProxyCommand(
                          //     wifi: _wifiController.text.trim(),
                          //     ip: _proxyIpController.text.trim(),
                          //     port: _proxyPortController.text.trim(),
                          //   ),
                          // );
                          var result = await context
                              .read<DeviceListCubit>()
                              .executeCommandForSelectedDevices(
                                command: SetProxyCommand(
                                  ip: _proxyIpController.text.trim(),
                                  port: _proxyPortController.text.trim(),
                                ),
                              );

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString(
                            'proxyIp',
                            _proxyIpController.text.trim(),
                          );
                          prefs.setString(
                            'proxyPort',
                            _proxyPortController.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Command finished!")),
                          );
                        },
                        child: Text("Set"),
                      ),
                      TextButton(
                        onPressed: () async {
                          var devices =
                              context
                                  .read<DeviceListCubit>()
                                  .getSelectedDevices();
                          if (devices.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select at least 1 device",
                                ),
                              ),
                            );
                            return;
                          }
                          await context
                              .read<DeviceListCubit>()
                              .executeCommandForSelectedDevices(
                                command: RemoveProxyCommand(),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Command finished!"),
                            ),
                          );
                        },
                        child: Text("Remove"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text('Geo', style: TextStyle(fontSize: 14)),
                        items: buildTimezoneList(),
                        value: _selectedTimeZone,
                        onChanged: (value) {
                          setState(() {
                            _selectedTimeZone = value;
                          });
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString('geo', value!);
                          });

                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          height: 40,
                          width: 100,
                        ),
                        dropdownStyleData: const DropdownStyleData(
                          maxHeight: 200,
                        ),
                        menuItemStyleData: const MenuItemStyleData(height: 40),
                        dropdownSearchData: DropdownSearchData(
                          searchController: _searchGeoController,
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
                              controller: _searchGeoController,
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
                            _searchGeoController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_selectedTimeZone == null ||
                          _selectedTimeZone!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select 1 timezone"),
                          ),
                        );
                        return;
                      }
                      var location =
                          timezoneCoordinates[_selectedTimeZone]?[Random()
                              .nextInt(2)];
                      if (location == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cannot find location")),
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

                      await context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: ChangeGeoCommand(
                              latitude: location['lat']!,
                              longitude: location['lon']!,
                              timeZone: timezoneMap[_selectedTimeZone]!,
                            ),
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Command finished!")),
                      );
                    },
                    child: Text("Change"),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text("Brightness", style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Slider(
                    min: 0,
                    value: _brightness,
                    max: 255,
                    onChanged: (double value) {
                      setState(() {
                        _brightness = value;
                      });
                    },
                    onChangeEnd: (double value) async {
                      await context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: SetBrightnessCommand(
                              brightness: value.toInt(),
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("Volume", style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Slider(
                    min: 0,
                    value: _volume.toDouble(),
                    max: 25,
                    onChanged: (double value) {
                      setState(() {
                        _volume = value.toInt();
                      });
                    },
                    onChangeEnd: (double value) {
                      context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: SetVolumeCommand(volume: value.toInt()),
                          );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("Always on"),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _isAlwaysOn,
                    onChanged: (value) async {
                      setState(() {
                        _isAlwaysOn = value;
                      });
                      context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: SetAlwaysOnCommand(value: value ? 1 : 0),
                          );
                    },
                  ),
                ),

                Gap(10),
                Text("Wifi"),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _isWifiOn,
                    onChanged: (value) async {
                      setState(() {
                        _isWifiOn = value;
                      });
                      context
                          .read<DeviceListCubit>()
                          .executeCommandForSelectedDevices(
                            command: SetWifiCommand(isOn: value),
                          );
                    },
                  ),
                ),
              ],
            ),
            Gap(10),
            Row(
              children: [
                Expanded(child: TextField(controller: _chPlayUrlController,
                  decoration: InputDecoration(
                    labelText: 'CH Play URL',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1),
                    ),
                  ),
                )),
                Gap(10),
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: () async {
                    if(_chPlayUrlController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a URL"),
                        ),
                      );
                      return;
                    }
                    context
                        .read<DeviceListCubit>()
                        .executeCommandForSelectedDevices(
                          command: OpenChPlayWithUrlCommand(url: _chPlayUrlController.text.trim()),
                        );
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                      'chPlayUrl',
                      _chPlayUrlController.text.trim(),
                    );
                  },
                ),
              ],
            ),
            Gap(50),
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: broadCastCommand,
                  builder:
                      (_, _, _) => DropdownButton<BroadCastCommandType>(
                        value: broadCastCommand.value,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        underline: Container(),
                        padding: EdgeInsets.symmetric(
                          vertical: 1,
                          horizontal: 10,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        onChanged: (BroadCastCommandType? value) {
                          // This is called when the user selects an item.
                          if (value != null) {
                            broadCastCommand.value = value;
                          }
                        },
                        items:
                            broadCastTypesMap.entries
                                .map(
                                  (entries) => DropdownMenuItem(
                                    value: entries.key,
                                    child: Text(entries.value),
                                  ),
                                )
                                .toList(),
                      ),
                ),
                TextButton(
                  child: Text("Run"),
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
                    await context
                        .read<DeviceListCubit>()
                        .executeCommandForSelectedDevices(
                          command: BroadCastCommand(
                            type: broadCastCommand.value,
                          ),
                        );
                  },
                ),
              ],
            ),
            Gap(10),
            _buildStateButtons(),
          ],
        ),
      ),
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

class ButtonState {
  final String text;
  final Command command;

  ButtonState({required this.text, required this.command});
}
