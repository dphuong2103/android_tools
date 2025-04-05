import 'package:android_tools/core/util/date_util.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/features/home/presentation/cubit/install_apk_tab_cubit.dart';
import 'package:android_tools/injection_container.dart';
import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../domain/entity/command.dart';

class InstallApkTab extends StatefulWidget {
  const InstallApkTab({super.key});

  @override
  State<InstallApkTab> createState() => _InstallApkTabState();
}

class _InstallApkTabState extends State<InstallApkTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstallApkTabCubit>(
      create: (context) => sl()..init(),
      child: InstallApkTabView(),
    );
  }
}

class InstallApkTabView extends StatefulWidget {
  const InstallApkTabView({super.key});

  @override
  State<InstallApkTabView> createState() => _InstallApkTabViewState();
}

class _InstallApkTabViewState extends State<InstallApkTabView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {},
      builder:
          (
            homeContext,
            homeState,
          ) => BlocConsumer<InstallApkTabCubit, InstallApkTabState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top:10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: state.isLoading ? null : () {
                            var hasSelectedDevice = homeState.devices
                                .firstWhereOrNull((device) => device.isSelected);
                            if (hasSelectedDevice == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select at least 1 device",
                                  ),
                                ),
                              );
                              return;
                            }
                            var selectedApks =
                                state.apks
                                    .where((apk) => apk.isSelected)
                                    .toList();
                            if (selectedApks.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select at least 1 apk"),
                                ),
                              );
                              return;
                            }

                            homeContext
                                .read<HomeCubit>()
                                .executeCommandForSelectedDevices(
                                  command: InstallApksCommand(
                                    selectedApks
                                        .map((apk) => apk.name)
                                        .toList(),
                                   ),
                                );
                          },
                          child: Text("Install"),
                        ),
                        Gap(10),
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.green),
                          onPressed:
                          state.isLoading
                              ? null
                              : () async {
                            context.read<InstallApkTabCubit>().refresh();
                          },
                          onLongPress: null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: DataTable2(
                      headingCheckboxTheme: const CheckboxThemeData(
                        side: BorderSide(width: 2.0),
                      ),
                      onSelectAll: (bool? isSelectAll) {
                        context.read<InstallApkTabCubit>().onSelectAll(
                          isSelectAll,
                        );
                      },
                      columns: [
                        DataColumn2(label: Text("Name")),
                        DataColumn2(
                          label: Text("Created At"),
                          onSort: (i, b) {},
                        ),
                        DataColumn2(label: Text("Modified At")),
                        // DataColumn2(label: Text("Type")),
                      ],
                      rows:
                          state.apks
                              .map(
                                (folder) => DataRow2(
                                  onSelectChanged: (bool? selected) {
                                    context
                                        .read<InstallApkTabCubit>()
                                        .onToggleSelectFile(
                                          apkName: folder.name,
                                          selected: selected ?? false,
                                        );
                                  },
                                  selected: folder.isSelected,
                                  cells: [
                                    DataCell(Text(folder.name)),
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
                ],
              );
            },
          ),
    );
  }
}
