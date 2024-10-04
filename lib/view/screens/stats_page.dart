import 'package:drinks/data/widgets/circle_items.dart';
import 'package:drinks/data/widgets/info_container.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:drinks/view/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late final Box<Drink> _drinksBox;

  // Data for calculations
  int totalDrinks = 0;
  int totalBeers = 0;
  int totalLiquor = 0;
  int totalWine = 0;
  DateTime? lastDrinkDate;
  int longestStreak = 0;
  int longestBreak = 0;

  @override
  void initState() {
    super.initState();
    _drinksBox = Hive.box<Drink>('drinksBox');
    _calculateStats();
  }

  void _calculateStats() {
    // Reset values
    totalDrinks = 0;
    totalBeers = 0;
    totalLiquor = 0;
    totalWine = 0;
    lastDrinkDate = null;
    longestStreak = 0;
    longestBreak = 0;

    // Iterate through drinks and update values
    final drinks = _drinksBox.values.toList();
    if (drinks.isNotEmpty) {
      lastDrinkDate = drinks.last.dateTime;

      for (var drink in drinks) {
        totalDrinks++;

        if (drink.drinkType == 'beer') {
          totalBeers++;
        } else if (drink.drinkType == 'drink') {
          totalLiquor++;
        } else if (drink.drinkType == 'wine') {
          totalWine++;
        }
      }
    }

    // Calculate percentages
    double beerPercentage =
        totalDrinks > 0 ? (totalBeers / totalDrinks) * 100 : 0;
    double liquorPercentage =
        totalDrinks > 0 ? (totalLiquor / totalDrinks) * 100 : 0;
    double winePercentage =
        totalDrinks > 0 ? (totalWine / totalDrinks) * 100 : 0;

    // ... (Implement logic for longestStreak and longestBreak)

    setState(() {}); // Update the UI
  }

  // @override
  // void dispose() {
  //   _drinksBox.clear();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('All Time',
            style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ));
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.grey[800],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 33.h,
                child: Stack(
                  children: [
                    Positioned(
                      left: 3.w,
                      top: 3.h,
                      child: CircleItem(
                        color: Colors.white,
                        label: 'Beer',
                        percentage:
                            '${totalBeers > 0 ? (totalBeers / totalDrinks * 100).toInt() : 0}%',
                        size: 23.h,
                        textColor: Colors.black,
                      ),
                    ),
                    Positioned(
                      // right: 7.w,
                      left: 54.w,
                      top: 3.h,
                      child: CircleItem(
                        color: Colors.grey[400]!,
                        label: 'Liquor',
                        percentage:
                            '${totalLiquor > 0 ? (totalLiquor / totalDrinks * 100).toInt() : 0}%',
                        size: 17.h,
                        textColor: Colors.black,
                      ),
                    ),
                    Positioned(
                      right: 7.w,
                      left: 30.w,
                      top: 20.h,
                      child: CircleItem(
                        color: Colors.grey[500]!,
                        label: 'Wine',
                        percentage:
                            '${totalWine > 0 ? (totalWine / totalDrinks * 100).toStringAsFixed(0) : 0}%',
                        size: 10.h,
                        textColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  InfoContainer(
                      label: 'TOTAL DRINKS', value: totalDrinks.toString()),
                  InfoContainer(
                    label: 'LAST DRINK',
                    value: lastDrinkDate != null
                        ? DateFormat('MMM d, yyyy').format(lastDrinkDate!)
                        : 'N/A',
                  ),
                  InfoContainer(
                      label: 'TOTAL BEERS', value: totalBeers.toString()),
                  InfoContainer(
                      label: 'LONGEST STREAK', value: '$longestStreak days'),
                  InfoContainer(
                      label: 'TOTAL LIQUOR', value: totalLiquor.toString()),
                  InfoContainer(
                      label: 'LONGEST BREAK', value: '$longestBreak days'),
                  InfoContainer(
                      label: 'TOTAL WINE', value: totalWine.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
