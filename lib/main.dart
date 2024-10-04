import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:sizer/sizer.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register the Drink adapter
  Hive.registerAdapter(DrinkAdapter());

  // Open the Hive box (you can name it anything you like)
  await Hive.openBox<Drink>('drinksBox');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: EasySplashScreen(
            logo: Image.asset('assets/png/wine.png'),
            title: const Text(
              "Drinks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            showLoader: true,
            loadingText: const Text("Loading..."),
            navigator: const HomePage(),
            durationInSeconds: 3,
          ),
        );
      },
    );
  }
}
