import 'dart:convert';

import 'package:android_tools/core/sub_window/sub_window.dart';
import 'package:android_tools/core/util/sub_window_util.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/features/phone_details/presentation/screens/phone_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class BackupTab extends StatefulWidget {
  const BackupTab({super.key});

  @override
  State<BackupTab> createState() => _BackupTabState();
}

class _BackupTabState extends State<BackupTab> {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state){},
      builder: (context, state) {
        return Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: (){
                context.read<HomeCubit>().executeCommand(command: BackupCommand(backupName: "test_backup_2"));
              }, child: Text("Backup")),
            ],
          ),
        );
      },
    );
  }
}
