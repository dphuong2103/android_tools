import 'package:intl/intl.dart';

String formatDateTime({DateTime? dateTime, String defaultValue = ""}) {
  if(dateTime == null) return defaultValue;
  return DateFormat('dd-MM-yyyy hh:mm:ss').format(dateTime);
}
