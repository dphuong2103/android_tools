enum LogType {
  ERROR,
  WARNING,
  DEBUG,
  INFO
}

class Log {
  final String title;
  final String? content;
  final DateTime dateTime;
  final LogType logType;

  Log({required this.title, this.content, required this.dateTime, required this.logType});
}
