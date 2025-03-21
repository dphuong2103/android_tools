import 'package:android_tools/core/util/date_util.dart';
import 'package:android_tools/core/util/sub_window_util.dart';
import 'package:android_tools/core/widget/sub_window_widget.dart';
import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/features/phone_details/presentation/cubit/phone_details_cubit.dart';
import 'package:android_tools/injection_container.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<HomeCubit>(create: (context) => sl()),
              BlocProvider<PhoneDetailsCubit>(
                create: (context) => sl()..init(serialNumber: device.ip),
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

class _PhoneDetailsViewState extends State<PhoneDetailsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    closeSubWindow(widget.device.ip);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneDetailsCubit, PhoneDetailsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: DataTable2(
                headingCheckboxTheme: const CheckboxThemeData(
                  side: BorderSide(width: 2.0),
                ),
                onSelectAll: (bool? isSelectAll) {
                  context.read<PhoneDetailsCubit>().onSelectAll(isSelectAll);
                },
                columns: const [
                  DataColumn2(label: Text("Name")),
                  DataColumn2(label: Text("Path")),
                  DataColumn2(label: Text("Created At")),
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
                                  formatDateTime(dateTime: folder.createdAt),
                                ),
                              ),
                              DataCell(
                                Text(
                                  formatDateTime(dateTime: folder.createdAt),
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
            ElevatedButton(
              onPressed: () {
                widget.windowController.close();
              },
              child: Text("Close window"),
            ),
          ],
        );
      },
    );
  }
}
