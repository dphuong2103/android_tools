import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/core/util/date_util.dart';
import 'package:flutter/material.dart';

class LogItem extends StatelessWidget {
  final Log log;

  const LogItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: _getLogColor(log.logType), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "[${formatDateTime(dateTime: log.dateTime)}] ${log.title}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getLogColor(log.logType),
            ),
          ),
          const SizedBox(height: 4),
          log.content == null ? Container() : SelectableText(
            log.content!,
            // Removed the `color` property so it uses the default theme color
          ),
        ],
      ),
    );
  }

  Color _getLogColor(LogType logType) {
    switch (logType) {
      case LogType.ERROR:
        return Colors.red;
      case LogType.WARNING:
        return Colors.orange;
      case LogType.DEBUG:
        return Colors.blue;
      case LogType.INFO:
      return Colors.green;
    }
  }
}
