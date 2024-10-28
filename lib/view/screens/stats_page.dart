import 'package:drinks/data/widgets/circle_items.dart';
import 'package:drinks/data/widgets/info_container.dart';
import 'package:drinks/data/widgets/bottom_nav_bar.dart';
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
  DateTime? firstDrinkDate;
  int longestStreak = 0;
  int longestBreak = 0;
  int totalDrinkDays = 0;
  int totalNonDrinkDays = 0;
  DateTime? earliestDrinkTime;
  DateTime? latestDrinkTime;

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
    firstDrinkDate = null;
    longestStreak = 0;
    longestBreak = 0;
    totalDrinkDays = 0;
    totalNonDrinkDays = 0;
    earliestDrinkTime = null;
    latestDrinkTime = null;

    int currentStreak = 0;
    int currentBreak = 0;
    DateTime? previousDate;

    // Iterate through drinks and update values
    final drinks = _drinksBox.values.toList();
    drinks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (drinks.isNotEmpty) {
      firstDrinkDate = drinks.first.dateTime;
      lastDrinkDate = drinks.last.dateTime;
      earliestDrinkTime = drinks.first.dateTime;
      latestDrinkTime = drinks.last.dateTime;

      for (var drink in drinks) {
        totalDrinks++;

        if (drink.drinkType == 'beer') {
          totalBeers++;
        } else if (drink.drinkType == 'drink') {
          totalLiquor++;
        } else if (drink.drinkType == 'wine') {
          totalWine++;
        }

        // Streak and Break Calculations
        if (previousDate != null) {
          Duration difference = drink.dateTime.difference(previousDate);
          if (difference.inDays <= 1) {
            // Consider it a streak
            currentStreak++;
            currentBreak = 0;
          } else {
            // It's a break
            currentBreak = difference.inDays;
            currentStreak = 0;
          }

          // Update longestStreak and longestBreak if needed
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
          if (currentBreak > longestBreak) {
            longestBreak = currentBreak;
          }
        }

        // Update earliestDrinkTime and latestDrinkTime
        if (drink.dateTime.isBefore(earliestDrinkTime!)) {
          earliestDrinkTime = drink.dateTime;
        }
        if (drink.dateTime.isAfter(latestDrinkTime!)) {
          latestDrinkTime = drink.dateTime;
        }

        previousDate = drink.dateTime;
      }

      // Calculate total drink days and non-drink days
      totalDrinkDays =
          drinks.map((drink) => drink.dateTime.toLocal().day).toSet().length;
      totalNonDrinkDays = DateTime.now().difference(firstDrinkDate!).inDays -
          totalDrinkDays +
          1;

      // totalNonDrinkDays =
      //     DateTimeRange(start: firstDrinkDate!, end: lastDrinkDate!)
      //             .duration
      //             .inDays -
      //         totalDrinkDays;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentages
    double beerPercentage =
        totalDrinks > 0 ? (totalBeers / totalDrinks) * 100 : 0;
    double liquorPercentage =
        totalDrinks > 0 ? (totalLiquor / totalDrinks) * 100 : 0;
    double winePercentage =
        totalDrinks > 0 ? (totalWine / totalDrinks) * 100 : 0;

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
              LayoutBuilder(
                builder: (context, constraints) {
                  double maxSize = constraints.maxWidth * 0.6;

                  return SizedBox(
                    height: 30.h,
                    child: Stack(
                      children: [
                        // Beer Circle
                        if (beerPercentage > 0)
                          Positioned(
                            left: 5.w,
                            child: CircleItem(
                              color: Colors.white,
                              label: 'Beer',
                              percentage: '${beerPercentage.toInt()}%',
                              size: beerPercentage < 50
                                  ? maxSize * (beerPercentage / 100) + 35
                                  : (maxSize * (beerPercentage / 100)),
                              textColor: Colors.black,
                            ),
                          ),

                        // Liquor Circle
                        if (liquorPercentage > 0)
                          Positioned(
                            left: 37.w,
                            child: CircleItem(
                              color: Colors.grey[400]!,
                              label: 'Liquor',
                              percentage: '${liquorPercentage.toInt()}%',
                              size: liquorPercentage < 50
                                  ? maxSize * (liquorPercentage / 100) + 35
                                  : (maxSize * (liquorPercentage / 100)),
                              textColor: Colors.black,
                            ),
                          ),

                        // Wine Circle
                        if (winePercentage > 0)
                          Positioned(
                            left: 25.w,
                            top: 13.h,
                            child: CircleItem(
                              color: Colors.grey[500]!,
                              label: 'Wine',
                              percentage: '${winePercentage.toInt()}%',
                              size: winePercentage < 50
                                  ? maxSize * (winePercentage / 100) + 35
                                  : (maxSize * (winePercentage / 100)),
                              textColor: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      InfoContainer(
                          label: 'TOTAL DRINKS', value: totalDrinks.toString()),
                      InfoContainer(
                          label: 'TOTAL BEERS', value: totalBeers.toString()),
                      InfoContainer(
                          label: 'TOTAL LIQUOR', value: totalLiquor.toString()),
                      InfoContainer(
                          label: 'TOTAL WINE', value: totalWine.toString()),
                      InfoContainer(
                          label: 'DRINK DAYS',
                          value: totalDrinkDays.toString()),
                      InfoContainer(
                          label: 'NON-DRINK DAYS',
                          value: totalNonDrinkDays.toString()),
                    ],
                  ),
                  Column(
                    children: [
                      InfoContainer(
                        label: 'LAST DRINK',
                        value: lastDrinkDate != null
                            ? _calculateDaysAgo(lastDrinkDate!)
                            : 'N/A',
                      ),
                      InfoContainer(
                        label: 'FIRST DRINK',
                        value: firstDrinkDate != null
                            ? _calculateDaysAgo(firstDrinkDate!)
                            : 'N/A',
                      ),
                      InfoContainer(
                          label: 'LONGEST STREAK',
                          value: '$longestStreak days'),
                      InfoContainer(
                          label: 'LONGEST BREAK', value: '$longestBreak days'),
                      InfoContainer(
                        label: 'EARLIEST DRINK',
                        value: earliestDrinkTime != null
                            ? DateFormat.jm().format(earliestDrinkTime!)
                            : 'N/A',
                      ),
                      InfoContainer(
                        label: 'LATEST DRINK',
                        value: latestDrinkTime != null
                            ? DateFormat.jm().format(latestDrinkTime!)
                            : 'N/A',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottumNavigationBar(),
    );
  }

  // Function to calculate days ago from a given date (you already have this)
  String _calculateDaysAgo(DateTime date) {
    Duration difference = DateTime.now().difference(date);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
