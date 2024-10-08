import 'package:drinks/data/enums/month_names.dart';
import 'package:drinks/models/bottom_nav_bar.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({super.key});

  @override
  _MonthlyPageState createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  // No need for ScrollController anymore
  DateTime _currentDate = DateTime.now();
  final List<String> drinkIcons = ['🍸', '🍷', '🍺'];
  late final Box<Drink> _drinksBox;

  // Variables to store monthly drink counts
  int totalDrinksForMonth = 0;
  int totalBeersForMonth = 0;
  int totalLiquorForMonth = 0;
  int totalWineForMonth = 0;

  @override
  void initState() {
    super.initState();
    _drinksBox = Hive.box<Drink>('drinksBox');
    _calculateMonthlyDrinkCounts(_currentDate); // Calculate for initial month
  }

  // Function to check if a date has any drinks
  bool _hasDrinks(DateTime date) {
    return _drinksBox.values.any((drink) {
      return drink.dateTime.year == date.year &&
          drink.dateTime.month == date.month &&
          drink.dateTime.day == date.day;
    });
  }

  // Function to calculate total drink counts for the DISPLAYED MONTH
  void _calculateMonthlyDrinkCounts(DateTime monthDate) {
    totalDrinksForMonth = 0;
    totalBeersForMonth = 0;
    totalLiquorForMonth = 0;
    totalWineForMonth = 0;

    // Iterate through the drinks in the Hive box
    for (var drink in _drinksBox.values) {
      // Check if the drink date matches the displayed month and year
      if (drink.dateTime.year == monthDate.year &&
          drink.dateTime.month == monthDate.month) {
        if (drink.drinkType == 'beer') {
          totalBeersForMonth++;
        } else if (drink.drinkType == 'drink') {
          totalLiquorForMonth++;
        } else if (drink.drinkType == 'wine') {
          totalWineForMonth++;
        }
        totalDrinksForMonth++;
      }
    }
  }

  // Function to calculate daily drink counts for a given month
  Map<int, int> _calculateDailyDrinkCounts(DateTime monthDate) {
    Map<int, int> dailyCounts = {};

    for (var drink in _drinksBox.values) {
      if (drink.dateTime.year == monthDate.year &&
          drink.dateTime.month == monthDate.month) {
        int day = drink.dateTime.day;
        dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      }
    }

    return dailyCounts;
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _calculateMonthlyDrinkCounts(_currentDate);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _calculateMonthlyDrinkCounts(_currentDate);
    });
  }

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
            _goToPreviousMonth();
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentDate.monthName(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '${_currentDate.year}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goToNextMonth,
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.grey[800],
      ),
      body: Container(
        color: Colors.black,
        child: _buildMonthView(_currentDate),
      ),
      bottomNavigationBar: const CustomBottumNavigationBar(),
    );
  }

  // Function to build the UI for a single month
  Widget _buildMonthView(DateTime monthDate) {
    int daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;

    // Calculate daily drink counts for the current month
    Map<int, int> dailyDrinkCounts = _calculateDailyDrinkCounts(monthDate);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${monthDate.monthName()} ${monthDate.year}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Sun',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Mon',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Tue',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Wed',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Thu',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Fri',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Sat',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 5),
            Flexible(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.7,
                ),
                itemBuilder: (context, dayIndex) {
                  DateTime day =
                      DateTime(monthDate.year, monthDate.month, dayIndex + 1);
                  int dayDrinkCount = dailyDrinkCounts[day.day] ?? 0;

                  return Center(
                    child: dayIndex < daysInMonth
                        ? GestureDetector(
                            onTap: () {
                              debugPrint('Tapped on: $day');
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Display drink count or circle indicator
                                dayDrinkCount > 0
                                    ? Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$dayDrinkCount',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${day.day}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          )
                        : Container(),
                  );
                },
                itemCount: 42, // 6 weeks x 7 days per week
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < drinkIcons.length; i++)
                  Row(
                    children: [
                      Text(
                        '${i == 0 ? totalLiquorForMonth : i == 1 ? totalWineForMonth : totalBeersForMonth} ', // Display monthly counts
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        drinkIcons[i],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                const Text(
                  "=  ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    '$totalDrinksForMonth',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white, thickness: 2),
          ],
        ),
      ),
    );
  }
}
