import 'package:android_tools/core/device_list/device.dart';
import 'package:android_tools/core/device_list/device_list_cubit.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/util/date_util.dart';
import 'package:android_tools/core/util/sub_window_util.dart';
import 'package:android_tools/core/widget/sub_window_widget.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/phone_details/presentation/cubit/phone_details_cubit.dart';
import 'package:android_tools/injection_container.dart';
import 'package:collection/collection.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class PhoneDetailsScreen extends StatelessWidget {
  const PhoneDetailsScreen({
    super.key,
    required this.windowController,
    required this.device,
  });

  final WindowController windowController;
  final Device device;

  @override
  Widget build(BuildContext context) {
    return SubWindowWidget(
      windowId: device.ip,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: Text(device.ip)),
          body: MultiBlocProvider(
            providers: [
              BlocProvider<DeviceListCubit>(create: (context) => sl()),
              BlocProvider<PhoneDetailsCubit>(
                create: (context) => sl()..init(serialNumber: device.ip),
                // ..embedScrcpy(device.ip),
              ),
            ],
            child: PhoneDetailsView(
              windowController: windowController,
              device: device,
            ),
          ),
        ),
      ),
    );
  }
}

class PhoneDetailsView extends StatefulWidget {
  final WindowController windowController;
  final Device device;

  const PhoneDetailsView({
    super.key,
    required this.windowController,
    required this.device,
  });

  @override
  State<PhoneDetailsView> createState() => _PhoneDetailsViewState();
}

enum SetUpPhoneOption { FlashRom, FlaskGApp, InstallMagisk, InstallApp, FlashTwrp, InstallEdXposed }

Map<SetUpPhoneOption, String> setUpPhoneOptionLabels = {
  SetUpPhoneOption.FlashRom: "1. Flash Rom",
  SetUpPhoneOption.FlaskGApp: "2. Flask GApp",
  SetUpPhoneOption.InstallMagisk: "3. Install Magisk",
  SetUpPhoneOption.InstallEdXposed: "4. Install EdXposed",
  SetUpPhoneOption.InstallApp: "5. Install Apps",
  SetUpPhoneOption.FlashTwrp: "Flash TWRP",
};

class _PhoneDetailsViewState extends State<PhoneDetailsView>
    with SingleTickerProviderStateMixin {
  final tabs = <Widget>[
    Tab(text: "RSS"),
    Tab(text: "Script"),
    Tab(text: "Setup"),
  ];
  late final TextEditingController eventsScriptController;
  late final TextEditingController replayEventsScriptController;
  late final TabController tabController;
  String? status;
  var setupPhoneOption = SetUpPhoneOption.FlashRom;

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    eventsScriptController = TextEditingController();
    replayEventsScriptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    closeSubWindow(widget.device.ip);
    tabController.dispose();
    eventsScriptController.dispose();
    replayEventsScriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneDetailsCubit, PhoneDetailsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          children: [
            TabBar(controller: tabController, tabs: tabs),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                var hasSelectDevice = state.backUpFolders
                                    ?.firstWhereOrNull(
                                      (folder) => folder.isSelected,
                                    );
                                if (hasSelectDevice == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please select at least 1 folder",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (await confirm(
                                  context,
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                    'Would you like to remove?',
                                  ),
                                  textOK: const Text('Yes'),
                                  textCancel: const Text('No'),
                                )) {
                                  if (context.mounted) {
                                    context
                                        .read<PhoneDetailsCubit>()
                                        .deleteSelectedFolder();
                                  }
                                }
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                            IconButton(
                              onPressed: () async {
                                var selectedFolders =
                                    state.backUpFolders
                                        ?.where((folder) => folder.isSelected)
                                        .toList();
                                if (selectedFolders == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please select 1 folder"),
                                    ),
                                  );
                                  return;
                                }
                                if (selectedFolders.length > 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please select only 1 folder",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (await confirm(
                                  context,
                                  title: const Text('Confirm Backup'),
                                  content: const Text(
                                    'Would you like to start backing up?',
                                  ),
                                  textOK: const Text('Yes'),
                                  textCancel: const Text('No'),
                                )) {
                                  if (context.mounted) {
                                    context.read<DeviceListCubit>().executeCommand(
                                      command: RestoreBackupCommand(
                                        backupName: selectedFolders.first.name,
                                      ),
                                      devices: [widget.device],
                                    );
                                  }
                                }
                              },
                              icon: Icon(Icons.restore, color: Colors.green),
                            ),
                          ],
                        ),
                        Expanded(
                          child: DataTable2(
                            headingCheckboxTheme: const CheckboxThemeData(
                              side: BorderSide(width: 2.0),
                            ),
                            onSelectAll: (bool? isSelectAll) {
                              context.read<PhoneDetailsCubit>().onSelectAll(
                                isSelectAll,
                              );
                            },
                            columns: [
                              DataColumn2(label: Text("Name")),
                              DataColumn2(label: Text("Path")),
                              DataColumn2(
                                label: Text("Created At"),
                                onSort: (i, b) {
                                  context
                                      .read<PhoneDetailsCubit>()
                                      .sortFolderByCreatedAt();
                                },
                              ),
                              DataColumn2(label: Text("Modified At")),
                              // DataColumn2(label: Text("Type")),
                            ],
                            rows:
                                state.backUpFolders
                                    ?.map(
                                      (folder) => DataRow2(
                                        onSelectChanged: (bool? selected) {
                                          context
                                              .read<PhoneDetailsCubit>()
                                              .onToggleSelectFolder(
                                                folderName: folder.name,
                                                selected: selected ?? false,
                                              );
                                        },
                                        selected: folder.isSelected,
                                        cells: [
                                          DataCell(Text(folder.name)),
                                          DataCell(Text(folder.path)),
                                          DataCell(
                                            Text(
                                              formatDateTime(
                                                dateTime: folder.createdAt,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatDateTime(
                                                dateTime: folder.createdAt,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList() ??
                                [],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            widget.windowController.close();
                          },
                          child: Text("Close window"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextFormField(
                                readOnly: state.isRecordingEvents,
                                controller: eventsScriptController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Events Script Name',
                                ),
                              ),
                            ),
                            Gap(10),
                            ElevatedButton(
                              onPressed: () {
                                if (eventsScriptController.text
                                    .trim()
                                    .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter a script name",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                state.isRecordingEvents
                                    ? context
                                        .read<PhoneDetailsCubit>()
                                        .stopRecordingEvents()
                                    : context
                                        .read<PhoneDetailsCubit>()
                                        .startRecordingEvents(
                                          serialNumber: widget.device.ip,
                                          eventsScriptName:
                                              eventsScriptController.text
                                                  .trim(),
                                        );
                              },
                              child: Text(
                                state.isRecordingEvents ? "Stop" : "Start",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextFormField(
                                controller: replayEventsScriptController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Events Script Name',
                                ),
                              ),
                            ),
                            Gap(10),
                            ElevatedButton(
                              onPressed: () {
                                if (replayEventsScriptController.text
                                    .trim()
                                    .isEmpty) {
                                  return;
                                }
                                context
                                    .read<PhoneDetailsCubit>()
                                    .replayEventFile2(
                                      serialNumber: widget.device.ip,
                                      eventsScriptName:
                                          replayEventsScriptController.text
                                              .trim(),
                                    );
                              },
                              child: Text("Replay"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        DropdownButton2<SetUpPhoneOption>(
                          items: _buildSetupPhoneOption(),
                          onChanged: (value) {
                            setState(() {
                              setupPhoneOption = value!;
                            });
                          },
                          value: setupPhoneOption,
                        ),
                        Gap(10),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              status = "Executing...";
                            });
                            CommandResult result;
                            switch (setupPhoneOption) {
                              case SetUpPhoneOption.FlashRom:
                                result = await context
                                    .read<PhoneDetailsCubit>()
                                    .flashRom(serialNumber: widget.device.ip);
                                break;
                              case SetUpPhoneOption.InstallMagisk:
                                result = await context
                                    .read<PhoneDetailsCubit>()
                                    .flashMagisk(
                                      serialNumber: widget.device.ip,
                                    );
                                break;
                              case SetUpPhoneOption.InstallApp:
                                result = await context
                                    .read<PhoneDetailsCubit>()
                                    .installApks(
                                      serialNumber: widget.device.ip,
                                    );
                                break;
                              case SetUpPhoneOption.FlaskGApp:
                                result = await context
                                    .read<PhoneDetailsCubit>()
                                    .flashGApp(serialNumber: widget.device.ip);
                              case SetUpPhoneOption.FlashTwrp:
                                result = await context
                                    .read<PhoneDetailsCubit>()
                                    .flashTwrp(serialNumber: widget.device.ip);
                              case SetUpPhoneOption.InstallEdXposed:
                                result = await context
                                    .read<PhoneDetailsCubit>()
                                    .installEdXposed(
                                      serialNumber: widget.device.ip,
                                    );
                                break;
                            }
                            if (result.success) {
                              setState(() {
                                status = "Success";
                              });
                            }else{
                              setState(() {
                                status = "${result.error} ${result.message}";
                              });
                            }
                          },
                          child: Text("Execute"),
                        ),
                        Gap(10),
                        if(status != null)
                          SelectableText(status!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<SetUpPhoneOption>> _buildSetupPhoneOption() {
    return setUpPhoneOptionLabels.entries.map((entry) {
      return DropdownMenuItem<SetUpPhoneOption>(
        value: entry.key,
        child: Text(
          entry.value,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }
}
