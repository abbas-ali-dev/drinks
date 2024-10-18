import 'package:drinks/data/enums/month_names.dart';
import 'package:drinks/models/bottom_nav_bar.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({super.key});

  @override
  _MonthlyPageState createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  DateTime _currentDate = DateTime.now();
  final List<String> drinkIcons = ['🍸', '🍷', '🍺'];
  late final Box<Drink> _drinksBox;

  int totalDrinksForMonth = 0;
  int totalBeersForMonth = 0;
  int totalLiquorForMonth = 0;
  int totalWineForMonth = 0;

  @override
  void initState() {
    super.initState();
    _drinksBox = Hive.box<Drink>('drinksBox');
    _calculateMonthlyDrinkCounts(_currentDate);
  }

  bool _hasDrinks(DateTime date) {
    return _drinksBox.values.any((drink) {
      return drink.dateTime.year == date.year &&
          drink.dateTime.month == date.month &&
          drink.dateTime.day == date.day;
    });
  }

  void _calculateMonthlyDrinkCounts(DateTime monthDate) {
    totalDrinksForMonth = 0;
    totalBeersForMonth = 0;
    totalLiquorForMonth = 0;
    totalWineForMonth = 0;

    for (var drink in _drinksBox.values) {
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

  Widget _buildMonthView(DateTime monthDate) {
    int daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;

    // Calculate daily drink counts for the current month
    Map<int, int> dailyDrinkCounts = _calculateDailyDrinkCounts(monthDate);

    // Calculate the offset for the first day of the month
    int firstDayWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    int offset = firstDayWeekday - 0; // Adjust for 0-based indexing

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
                  // Apply the offset to align days correctly
                  int adjustedDayIndex = dayIndex + 1 - offset;

                  DateTime day = DateTime(
                      monthDate.year, monthDate.month, adjustedDayIndex);
                  int dayDrinkCount = dailyDrinkCounts[day.day] ?? 0;

                  return Center(
                    child:
                        adjustedDayIndex >= 1 && adjustedDayIndex <= daysInMonth
                            ? GestureDetector(
                                onTap: () {
                                  debugPrint('Tapped on: $day');
                                  // Navigate to home page with selected date
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => const HomePage(),
                                  //     settings: RouteSettings(
                                  //       arguments: day, // Pass the selected date
                                  //     ),
                                  //   ),
                                  // );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
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
                itemCount: 42,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < drinkIcons.length; i++)
                  Row(
                    children: [
                      Text(
                        '${i == 0 ? totalLiquorForMonth : i == 1 ? totalWineForMonth : totalBeersForMonth} ',
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
