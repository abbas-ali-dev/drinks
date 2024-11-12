import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(); // Initialize date formatting
  Intl.defaultLocale = 'en_US'; // Set the default locale to US English

  // Initialize Hive
  await Hive.initFlutter();

  // Register the Drink adapter
  Hive.registerAdapter(DrinkAdapter());

  // Open the Hive box (you can name it anything you like)
  await Hive.openBox<Drink>('drinksBox');
  await Hive.openBox('settingsBox'); // Open the settings box

  // Initialize Branch.io
  FlutterBranchSdk.initSession().listen((deepLinkData) {
    print('Deep link data: $deepLinkData');
  });

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
          debugShowCheckedModeBanner: false,
          home: EasySplashScreen(
            logo: Image.asset('assets/png/drink.png'),
            title: const Text(
              "Drinks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 62, 62, 62),
            showLoader: true,
            loaderColor: Colors.white,
            loadingText: const Text(
              "Loading...",
              style: TextStyle(color: Colors.white),
            ),
            navigator: const HomePage(),
            durationInSeconds: 3,
          ),
        );
      },
    );
  }
}
