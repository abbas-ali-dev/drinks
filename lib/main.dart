import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:drinks/models/drink_model.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register the Drink adapter
  // Hive.registerAdapter(DrinkAdapter());

  // Open the Hive box (you can name it anything you like)
  await Hive.openBox<Drink>('drinksBox');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage());
  }
}
