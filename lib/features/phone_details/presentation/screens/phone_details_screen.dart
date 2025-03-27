import 'package:android_tools/core/util/date_util.dart';
import 'package:android_tools/core/util/sub_window_util.dart';
import 'package:android_tools/core/widget/sub_window_widget.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/features/phone_details/presentation/cubit/phone_details_cubit.dart';
import 'package:android_tools/injection_container.dart';
import 'package:collection/collection.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
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
              BlocProvider<HomeCubit>(create: (context) => sl()),
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

class _PhoneDetailsViewState extends State<PhoneDetailsView>
    with SingleTickerProviderStateMixin {
  final tabs = <Widget>[Tab(text: "RSS"), Tab(text: "Script")];
  late final TextEditingController eventsScriptController;
  late final TextEditingController replayEventsScriptController;
  late final TabController tabController;

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
                                    context.read<HomeCubit>().executeCommand(
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
                                    .isEmpty)
                                  return;
                                context
                                    .read<PhoneDetailsCubit>()
                                    .replayEventFile(
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
