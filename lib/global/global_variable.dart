import 'package:hive/hive.dart';

// global_variables.dart

String selectedTimeFormatGlobally = _loadTimeFormatFromHive();
String selectedCutoffTimeGlobally = _loadCutoffTimeFromHive();

String _loadTimeFormatFromHive() {
  return Hive.box('settingsBox').get('timeFormat') ?? '12 Hour';
}

String _loadCutoffTimeFromHive() {
  return Hive.box('settingsBox').get('cutoffTime') ?? '06:00 AM';
}
