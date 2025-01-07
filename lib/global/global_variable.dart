import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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

final selectedMonthNotifier = ValueNotifier<DateTime>(DateTime.now());

final selectedStatsYearNotifier = ValueNotifier<int>(DateTime.now().year);

final isAllTimeViewNotifier = ValueNotifier<bool>(true);

var showAdMobGlobally = ValueNotifier<bool>(true);

final ValueNotifier<bool> isMenuOpenNotifier = ValueNotifier<bool>(false);

Future checkConectivity() async {
  await Connectivity().checkConnectivity().then((result) {
    // Check first item in the list
    if (result.first == ConnectivityResult.none) {
      print('No network connection');
      showAdMobGlobally.value = false;
    } else {
      showAdMobGlobally.value = true;
      print('Network connection available');
    }
  });
}

// Add these helper methods at the top of the class
int getCutoffHour() {
  String timeStr = selectedCutoffTimeGlobally;
  List<String> timeParts = timeStr.split(':');
  return int.parse(timeParts[0]);
}

int getCutoffMinutes() {
  String timeStr = selectedCutoffTimeGlobally;
  List<String> timeParts = timeStr.split(':');
  String minuteStr = timeParts[1].split(' ')[0];
  return int.parse(minuteStr);
}

DateTime adjustDateByCutoff(DateTime drinkDate) {
  int cutoffHour = getCutoffHour();
  int cutoffMinutes = getCutoffMinutes();
  DateTime cutoffTime = DateTime(
    drinkDate.year,
    drinkDate.month,
    drinkDate.day,
    cutoffHour,
    cutoffMinutes,
  );
  return drinkDate.isBefore(cutoffTime)
      ? drinkDate.subtract(const Duration(days: 1))
      : drinkDate;
}
