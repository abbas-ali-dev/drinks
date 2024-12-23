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
