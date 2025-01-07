import 'package:drinks/data/widgets/info_container.dart';
import 'package:drinks/data/widgets/bottom_nav_bar.dart';
import 'package:drinks/global/global_variable.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/services/adMob.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  BannerAd? _bannerAd;
  late final Box<Drink> _drinksBox;

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
    checkConectivity();
    if (showAdMobGlobally.value == true) {
      _bannerAd = AdHelper.createBannerAd(() {
        setState(() {});
      });
    }
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
      if (year == null) return true;
      return drink.dateTime.year == year;
    }).toList();

    drinks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (drinks.isNotEmpty) {
      firstDrinkDate = drinks.first.dateTime;
      lastDrinkDate = drinks.last.dateTime;

      Map<DateTime, bool> drinkDays = {};

      int cutoffHour = getCutoffHour();
      int cutoffMinutes = getCutoffMinutes();

      DateTime cutoffTime = DateTime(2000, 1, 1, cutoffHour, cutoffMinutes);
      DateTime? earliestTimeOfDay;
      DateTime? latestTimeOfDay;

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
        DateTime adjustedDate = adjustDateByCutoff(drink.dateTime);
        DateTime dateKey = DateTime(
          adjustedDate.year,
          adjustedDate.month,
          adjustedDate.day,
        );
        drinkDays[dateKey] = true;

        // Normalize drink time to same reference date for comparison
        DateTime normalizedTime =
            DateTime(2000, 1, 1, drink.dateTime.hour, drink.dateTime.minute);

        // Adjust comparison based on cutoff time
        if (normalizedTime.isBefore(cutoffTime)) {
          // This is a "late" drink (before cutoff)
          if (latestTimeOfDay == null ||
              normalizedTime.isAfter(DateTime(
                  2000, 1, 1, latestTimeOfDay.hour, latestTimeOfDay.minute))) {
            latestTimeOfDay = drink.dateTime;
          }
        } else {
          // This is an "early" drink (after cutoff)
          if (earliestTimeOfDay == null ||
              normalizedTime.isBefore(DateTime(2000, 1, 1,
                  earliestTimeOfDay.hour, earliestTimeOfDay.minute))) {
            earliestTimeOfDay = drink.dateTime;
          }
        }
      }

      // If we haven't found any drinks in either category, use all drinks for comparison
      if (earliestTimeOfDay == null || latestTimeOfDay == null) {
        for (var drink in drinks) {
          DateTime normalizedTime =
              DateTime(2000, 1, 1, drink.dateTime.hour, drink.dateTime.minute);

          if (earliestTimeOfDay == null ||
              normalizedTime.isBefore(DateTime(2000, 1, 1,
                  earliestTimeOfDay.hour, earliestTimeOfDay.minute))) {
            earliestTimeOfDay = drink.dateTime;
          }

          if (latestTimeOfDay == null ||
              normalizedTime.isAfter(DateTime(
                  2000, 1, 1, latestTimeOfDay.hour, latestTimeOfDay.minute))) {
            latestTimeOfDay = drink.dateTime;
          }
        }
      }

      earliestDrinkTime = earliestTimeOfDay;
      latestDrinkTime = latestTimeOfDay;

      // Calculate longest streak
      int currentStreak = 0;
      int maxStreak = 0;
      List<DateTime> dates = drinkDays.keys.toList()..sort();

      DateTime now = DateTime.now();
      int currentYear = now.year;

      if (year == currentYear) {
        // Current year calculation with inclusive dates
        DateTime yearStart = DateTime(currentYear, 1, 1);
        DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

        // Calculate total days including the current day
        int daysElapsed = endDate.difference(yearStart).inDays;

        // Count drink days with inclusive date range
        int drinksInCurrentPeriod = drinkDays.keys
            .where((date) => date.year == currentYear && !date.isAfter(endDate))
            .length;

        totalNonDrinkDays = daysElapsed - drinksInCurrentPeriod;
      } else if (year != null) {
        List<DateTime> yearDrinks = drinks
            .where((drink) => drink.dateTime.year == year)
            .map((drink) => drink.dateTime)
            .toList()
          ..sort();

        if (yearDrinks.isNotEmpty) {
          DateTime firstDrinkOfYear = yearDrinks.first;
          // Set end time to last moment of the year
          DateTime yearEnd = DateTime(year, 12, 31, 23, 59, 59);

          // Inclusive day count
          int totalDays = yearEnd.difference(firstDrinkOfYear).inDays;

          int drinkDaysCount = drinkDays.keys
              .where((date) =>
                  date.year == year &&
                  !date.isBefore(firstDrinkOfYear) &&
                  !date.isAfter(yearEnd))
              .length;

          totalNonDrinkDays = totalDays - drinkDaysCount;
        }
      } // Longest Break calculation
      if (year == null) {
        // All Time view
        // For drink days - use all dates in drinkDays
        totalDrinkDays = drinkDays.length;

        // For non-drink days - calculate from first ever drink to now
        if (dates.isNotEmpty) {
          DateTime firstEverDrink = dates.first;
          DateTime now = DateTime.now();
          int totalDays = now.difference(firstEverDrink).inDays;
          totalNonDrinkDays = totalDays - totalDrinkDays;
        }

        // For longest streak - use all dates without year filtering
        // (existing streak calculation logic remains unchanged)

        // For longest break - calculate across all years
        if (dates.isNotEmpty) {
          longestBreak = 0;
          int currentBreak = 0;

          for (DateTime date = dates.first;
              date.isBefore(DateTime.now().add(const Duration(days: 1)));
              date = date.add(const Duration(days: 1))) {
            String dateKey = "${date.year}-${date.month}-${date.day}";
            if (!drinkDays.keys
                .any((d) => "${d.year}-${d.month}-${d.day}" == dateKey)) {
              currentBreak++;
              if (currentBreak > longestBreak) {
                longestBreak = currentBreak;
              }
            } else {
              currentBreak = 0;
            }
          }
        }
      }
      if (dates.isNotEmpty && year != null) {
        longestBreak = 0;
        List<DateTime> yearDates =
            dates.where((date) => date.year == year).toList()..sort();

        if (yearDates.isNotEmpty) {
          DateTime startDate =
              (year == currentYear) ? DateTime(year, 1, 1) : yearDates.first;
          DateTime endDate =
              (year == currentYear) ? now : DateTime(year, 12, 31);

          Set<String> drinkDates = yearDates
              .map((date) => "${date.year}-${date.month}-${date.day}")
              .toSet();

          int currentBreak = 0;
          for (DateTime date = startDate;
              date.isBefore(endDate.add(const Duration(days: 1)));
              date = date.add(const Duration(days: 1))) {
            String dateKey = "${date.year}-${date.month}-${date.day}";

            if (!drinkDates.contains(dateKey)) {
              currentBreak++;
              if (currentBreak > longestBreak) {
                longestBreak = currentBreak;
              }
            } else {
              currentBreak = 0;
            }
          }
        }
      }

      for (int i = 0; i < dates.length; i++) {
        if (i > 0) {
          final difference = dates[i].difference(dates[i - 1]).inDays;
          if (difference == 1) {
            currentStreak++;
            if (currentStreak > maxStreak) {
              maxStreak = currentStreak;
            }
          } else {
            currentStreak = 0;
          }
        }
      }

      longestStreak = maxStreak + 1;
      totalDrinkDays = drinkDays.length;
    }

    setState(() {});
  }

  String _calculateDaysAgo(DateTime date) {
    Duration difference = DateTime.now().difference(date);
    int daysAgo = difference.inDays;

    if (daysAgo == 0) {
      return 'Today';
    } else if (daysAgo == 1) {
      return 'Yesterday';
    } else {
      return '$daysAgo days ago';
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    isAllTimeViewNotifier.value = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AdHelper.getBannerAdWidget(_bannerAd),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isMenuOpenNotifier.value) {
                  isMenuOpenNotifier.value = false;
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      // Update color logic here
                      color: (isAllTimeViewNotifier.value ||
                              _getAvailableYears().indexOf(selectedYear) > 0)
                          ? Colors.white
                          : Colors.grey[700],
                      icon: const Icon(Icons.arrow_back_ios, size: 40),
                      onPressed: () {
                        setState(() {
                          if (isAllTimeViewNotifier.value) {
                            isAllTimeViewNotifier.value = false;
                            selectedYear = _getAvailableYears().last;
                          } else {
                            int currentIndex =
                                _getAvailableYears().indexOf(selectedYear);
                            if (currentIndex > 0) {
                              selectedYear =
                                  _getAvailableYears()[currentIndex - 1];
                            }
                          }
                          _calculateStats(isAllTimeViewNotifier.value
                              ? null
                              : selectedYear);
                          selectedStatsYearNotifier.value = selectedYear;
                        });
                      },
                    ),
                  ),
                  title: Text(
                    isAllTimeViewNotifier.value
                        ? 'All Time'
                        : selectedYear.toString(),
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      color: (!isAllTimeViewNotifier.value &&
                              _getAvailableYears().indexOf(selectedYear) <
                                  _getAvailableYears().length)
                          ? Colors.white
                          : Colors.grey[700],
                      icon: const Icon(Icons.arrow_forward_ios, size: 40),
                      onPressed: () {
                        setState(() {
                          if (!isAllTimeViewNotifier.value) {
                            int currentIndex =
                                _getAvailableYears().indexOf(selectedYear);
                            if (currentIndex <
                                _getAvailableYears().length - 1) {
                              selectedYear =
                                  _getAvailableYears()[currentIndex + 1];
                              _calculateStats(selectedYear);
                            } else {
                              isAllTimeViewNotifier.value = true;
                              _calculateStats(null);
                            }
                            selectedStatsYearNotifier.value = selectedYear;
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
                            drinkCounts.sort(
                                (a, b) => b['value'].compareTo(a['value']));

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
                              label: totalDrinkDays == 1
                                  ? 'DRINK DAY'
                                  : 'DRINK DAYS',
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
                              value: longestStreak == 1
                                  ? '1 day'
                                  : '$longestStreak days',
                            ),
                          ),
                          Expanded(
                            child: InfoContainer(
                              label: 'LONGEST BREAK',
                              value: longestBreak == 1
                                  ? '1 day'
                                  : '$longestBreak days',
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
              ),
            ),
          ),
        ],
      ),
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
