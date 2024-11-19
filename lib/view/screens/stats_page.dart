import 'package:drinks/data/widgets/circle_items.dart';
import 'package:drinks/data/widgets/info_container.dart';
import 'package:drinks/data/widgets/bottom_nav_bar.dart';
import 'package:drinks/models/drink_model.dart';
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
  bool isAllTime = true;
  int selectedYear = DateTime.now().year;

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
    _calculateStats(null); // Start with all-time stats
  }

  void _calculateStats(int? year) {
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

    final drinks = _drinksBox.values.where((drink) {
      if (year == null) {
        return true;
      }
      return drink.dateTime.year == year;
    }).toList();

    drinks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (drinks.isNotEmpty) {
      firstDrinkDate = drinks.first.dateTime;
      lastDrinkDate = drinks.last.dateTime;
      earliestDrinkTime = drinks.first.dateTime;
      latestDrinkTime = drinks.last.dateTime;

      Map<DateTime, bool> drinkDays = {};

      for (var drink in drinks) {
        totalDrinks++;

        if (drink.drinkType == 'beer') {
          totalBeers++;
        } else if (drink.drinkType == 'drink') {
          totalLiquor++;
        } else if (drink.drinkType == 'wine') {
          totalWine++;
        }

        DateTime dateKey = DateTime(
          drink.dateTime.year,
          drink.dateTime.month,
          drink.dateTime.day,
        );
        drinkDays[dateKey] = true;

        if (drink.dateTime.isBefore(earliestDrinkTime!)) {
          earliestDrinkTime = drink.dateTime;
        }
        if (drink.dateTime.isAfter(latestDrinkTime!)) {
          latestDrinkTime = drink.dateTime;
        }
      }

      // Calculate longest streak
      int currentStreak = 0;
      int maxStreak = 0;
      List<DateTime> dates = drinkDays.keys.toList()..sort();

      for (int i = 0; i < dates.length; i++) {
        if (i > 0) {
          final difference = dates[i].difference(dates[i - 1]).inDays;
          if (difference == 1) {
            currentStreak++;
            if (currentStreak > maxStreak) {
              maxStreak = currentStreak;
            }
          } else {
            if (difference > longestBreak) {
              longestBreak = difference - 1;
            }
            currentStreak = 0;
          }
        }
      }

      longestStreak = maxStreak + 1;
      totalDrinkDays = drinkDays.length;

      if (year == DateTime.now().year || year == null) {
        totalNonDrinkDays = DateTime.now().difference(firstDrinkDate!).inDays -
            totalDrinkDays +
            1;
      } else {
        totalNonDrinkDays =
            (DateTime(year + 1).difference(DateTime(year)).inDays) -
                totalDrinkDays;
      }
    }

    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
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
          icon: const Icon(Icons.arrow_back, size: 40),
          onPressed: () {
            setState(() {
              if (isAllTime) {
                isAllTime = false;
                selectedYear = DateTime.now().year;
              } else {
                selectedYear--;
              }
              _calculateStats(isAllTime ? null : selectedYear);
            });
          },
        ),
        title: Text(
          isAllTime ? 'All Time' : selectedYear.toString(),
          style: const TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward, size: 40),
            onPressed: () {
              setState(() {
                if (!isAllTime && selectedYear < DateTime.now().year) {
                  selectedYear++;
                  _calculateStats(selectedYear);
                } else if (!isAllTime && selectedYear == DateTime.now().year) {
                  isAllTime = true;
                  _calculateStats(null);
                }
              });
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
              if (beerPercentage == 0 &&
                  liquorPercentage == 0 &&
                  winePercentage == 0)
                SizedBox(
                  height: 3.h,
                )
              else
                SizedBox(
                  height: 30.h,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double baseSize = 200;

                      return Stack(
                        children: [
                          if (liquorPercentage > 0)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: CircleItem(
                                color: Colors.grey[300]!,
                                label: 'Liquor',
                                percentage: '${liquorPercentage.toInt()}%',
                                size: liquorPercentage < 50
                                    ? baseSize * (liquorPercentage / 70)
                                    : baseSize * (liquorPercentage / 100),
                                textColor: Colors.black,
                              ),
                            ),
                          if (winePercentage > 0)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: CircleItem(
                                color: Colors.grey[300]!,
                                label: 'Wine',
                                percentage: '${winePercentage.toInt()}%',
                                size: winePercentage < 50
                                    ? baseSize * (winePercentage / 70)
                                    : baseSize * (winePercentage / 100),
                                textColor: Colors.black,
                              ),
                            ),
                          if (beerPercentage > 0)
                            Positioned(
                              bottom: 10,
                              left: (MediaQuery.of(context).size.width / 2) -
                                  (baseSize * (beerPercentage / 100)) / 1.2,
                              child: CircleItem(
                                color: Colors.grey[300]!,
                                label: 'Beer',
                                percentage: '${beerPercentage.toInt()}%',
                                size: beerPercentage < 50
                                    ? baseSize * (beerPercentage / 70)
                                    : baseSize * (beerPercentage / 100),
                                textColor: Colors.black,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
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
                          label: 'TOTAL LIQUOR', value: totalLiquor.toString()),
                      InfoContainer(
                          label: 'TOTAL WINE', value: totalWine.toString()),
                      InfoContainer(
                          label: 'TOTAL BEERS', value: totalBeers.toString()),
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
}
