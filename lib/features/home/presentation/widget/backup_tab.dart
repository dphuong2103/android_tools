import 'dart:convert';

import 'package:android_tools/core/sub_window/sub_window.dart';
import 'package:android_tools/core/util/sub_window_util.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BackupTab extends StatefulWidget {
  const BackupTab({super.key});

  @override
  State<BackupTab> createState() => _BackupTabState();
}

class _BackupTabState extends State<BackupTab> {
  late final TextEditingController _backupNameController;
  late final TextEditingController _restoreNameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _backupNameController = TextEditingController();
    _restoreNameController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _backupNameController.dispose();
    _restoreNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Center(
          child: Column(
            children: [
              Gap(10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Backup Name',
                      ),
                      controller: _backupNameController,
                    ),
                  ),
                  Gap(5),
                  SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      onPressed: () {
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
                        if (_backupNameController.text.trim().isNotEmpty) {
                          context.read<HomeCubit>().executeCommandForSelectedDevices(
                            command: BackupCommand(
                              backupName: _backupNameController.text,
                            ),
                          );
                        }
                      },
                      child: Text("Backup"),
                    ),
                  ),
                ],
              ),
              Gap(10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _restoreNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Backup Name',
                      ),
                    ),
                  ),
                  Gap(5),
                  SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      onPressed: () {
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
                        if (_restoreNameController.text.trim().isNotEmpty) {
                          context.read<HomeCubit>().executeCommandForSelectedDevices(
                            command: RestoreBackupCommand(
                              backupName: _restoreNameController.text,
                            ),
                          );
                        }
                      },
                      child: Text("Restored"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
