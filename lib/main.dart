import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/haier_mall/coin_history_screen.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'view/haier_mall/daily_checkIn_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterBranchSdk.init(
    // useTestKey: false,
    enableLogging: true,
  );
  FlutterBranchSdk.validateSDKIntegration();

  await initializeDateFormatting(); // Initialize date formatting
  Intl.defaultLocale = 'en_US'; // Set the default locale to US English

  // Initialize Hive
  await Hive.initFlutter();

  // Register the Drink adapter
  Hive.registerAdapter(DrinkAdapter());

  // Open the Hive box (you can name it anything you like)
  await Hive.openBox<Drink>('drinksBox');
  await Hive.openBox('settingsBox'); // Open the settings box

  // Add AdMob initialization here
  await MobileAds.instance.initialize();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          color: Colors.black,
          title: 'Happy Hours',
          debugShowCheckedModeBanner: false,
          home: EasySplashScreen(
            backgroundImage: const AssetImage('assets/png/splash_screen.png'),
            showLoader: false,
            navigator: const HomePage(),
            durationInSeconds: 3,
          ),
        );
      },
    );
  }
}
