import 'package:drinks/data/widgets/info_container.dart';
import 'package:drinks/data/widgets/bottom_nav_bar.dart';
import 'package:drinks/global/global_variable.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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
    selectedStatsYearNotifier.value = DateTime.now().year;
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
        // Adjust the date based on cutoff time
        DateTime adjustedDate = _adjustDateByCutoff(drink.dateTime);
        DateTime dateKey = DateTime(
          adjustedDate.year,
          adjustedDate.month,
          adjustedDate.day,
        );
        drinkDays[dateKey] = true;
        // Update earliest/latest drink times using adjusted date
        if (earliestDrinkTime == null ||
            adjustedDate.isBefore(earliestDrinkTime!)) {
          earliestDrinkTime = drink.dateTime;
        }
        if (latestDrinkTime == null || adjustedDate.isAfter(latestDrinkTime!)) {
          latestDrinkTime = drink.dateTime;
        }

        // DateTime dateKey = DateTime(
        //   drink.dateTime.year,
        //   drink.dateTime.month,
        //   drink.dateTime.day,
        // );
        // drinkDays[dateKey] = true;

        // if (drink.dateTime.isBefore(earliestDrinkTime!)) {
        //   earliestDrinkTime = drink.dateTime;
        // }
        // if (drink.dateTime.isAfter(latestDrinkTime!)) {
        //   latestDrinkTime = drink.dateTime;
        // }
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios, size: 40),
          onPressed: () {
            setState(() {
              if (isAllTime) {
                isAllTime = false;
                selectedYear = _getAvailableYears().last;
                print(selectedYear.toString());
              } else {
                int currentIndex = _getAvailableYears().indexOf(selectedYear);
                if (currentIndex > 0) {
                  selectedYear = _getAvailableYears()[currentIndex - 1];
                }
                print(selectedYear.toString());
              }
              _calculateStats(isAllTime ? null : selectedYear);
              print("---->${selectedYear.toString()}");
              selectedStatsYearNotifier.value = selectedYear;
              print(selectedStatsYearNotifier.value.toString());
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
            icon: const Icon(Icons.arrow_forward_ios, size: 40),
            onPressed: () {
              setState(() {
                if (!isAllTime) {
                  int currentIndex = _getAvailableYears().indexOf(selectedYear);
                  if (currentIndex < _getAvailableYears().length - 1) {
                    selectedYear = _getAvailableYears()[currentIndex + 1];
                    _calculateStats(selectedYear);
                  } else {
                    isAllTime = true;
                    _calculateStats(null);
                  }
                  print("+++++>${selectedYear.toString()}");
                  selectedStatsYearNotifier.value = selectedYear;
                  print(selectedStatsYearNotifier.value.toString());
                }
              });
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.grey[800],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Expanded(
                  child: InfoContainer(
                    label: 'TOTAL DRINKS',
                    value: totalDrinks.toString(),
                  ),
                ),
                ...(() {
                  List<Map<String, dynamic>> drinkCounts = [
                    {'label': 'TOTAL LIQUOR', 'value': totalLiquor},
                    {'label': 'TOTAL WINE', 'value': totalWine},
                    {'label': 'TOTAL BEERS', 'value': totalBeers},
                  ];

                  // Sort in descending order based on value
                  drinkCounts.sort((a, b) => b['value'].compareTo(a['value']));

                  // Return sorted InfoContainers
                  return drinkCounts
                      .map((drink) => Expanded(
                            child: InfoContainer(
                              label: drink['label'],
                              value: drink['value'].toString(),
                            ),
                          ))
                      .toList();
                })(),
                Expanded(
                  child: InfoContainer(
                    label: totalDrinkDays == 1 ? 'DRINK DAY' : 'DRINK DAYS',
                    value: totalDrinkDays.toString(),
                  ),
                ),
                Expanded(
                  child: InfoContainer(
                    label: totalNonDrinkDays == 1
                        ? 'NON-DRINK DAY'
                        : 'NON-DRINK DAYS',
                    value: totalNonDrinkDays <= 0
                        ? '0'
                        : totalNonDrinkDays.toString(),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Expanded(
                  child: InfoContainer(
                    label: 'LAST DRINK',
                    value: lastDrinkDate != null
                        ? _calculateDaysAgo(lastDrinkDate!)
                        : 'N/A',
                  ),
                ),
                Expanded(
                  child: InfoContainer(
                    label: 'FIRST DRINK',
                    value: firstDrinkDate != null
                        ? _calculateDaysAgo(firstDrinkDate!)
                        : 'N/A',
                  ),
                ),
                Expanded(
                  child: InfoContainer(
                    label: 'LONGEST STREAK',
                    value: longestStreak == 1 ? '1 day' : '$longestStreak days',
                  ),
                ),
                Expanded(
                  child: InfoContainer(
                    label: 'LONGEST BREAK',
                    value: longestBreak == 1 ? '1 day' : '$longestBreak days',
                  ),
                ),
                Expanded(
                  child: InfoContainer(
                    label: 'EARLIEST DRINK',
                    value: earliestDrinkTime != null
                        ? DateFormat.jm().format(earliestDrinkTime!)
                        : 'N/A',
                  ),
                ),
                Expanded(
                  child: InfoContainer(
                    label: 'LATEST DRINK',
                    value: latestDrinkTime != null
                        ? DateFormat.jm().format(latestDrinkTime!)
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottumNavigationBar(),
    );
  }

  List<int> _getAvailableYears() {
    Set<int> years = {};

    // Add years from logged drinks
    for (var drink in _drinksBox.values) {
      years.add(drink.dateTime.year);
    }

    // Add current year if not already present
    years.add(DateTime.now().year);

    // Convert to sorted list
    List<int> yearsList = years.toList()..sort();

    print("Selected Year notifier: ${selectedStatsYearNotifier.value}");
    return yearsList;
  }
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

DateTime _adjustDateByCutoff(DateTime drinkDate) {
  int cutoffHour = getCutoffHour();
  int cutoffMinutes = getCutoffMinutes();

  DateTime cutoffTime = DateTime(
    drinkDate.year,
    drinkDate.month,
    drinkDate.day,
    cutoffHour,
    cutoffMinutes,
  );

  if (drinkDate.isBefore(cutoffTime)) {
    return drinkDate.subtract(const Duration(days: 1));
  }
  return drinkDate;
}
