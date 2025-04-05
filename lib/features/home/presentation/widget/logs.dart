import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'log_item.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  late final ScrollController logsScrollController;

  @override
  void initState() {
    logsScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    logsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogCubit, LogState>(
      listener: (context, logState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration(milliseconds: 50), () {
            if (logsScrollController.hasClients) {
              logsScrollController.animateTo(
                logsScrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });
      },
      builder: (context, logState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<LogCubit>().clearLogs();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                controller: logsScrollController,
                itemCount: logState.logs.length,
                itemBuilder: (context, index) {
                  return LogItem(log: logState.logs[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
