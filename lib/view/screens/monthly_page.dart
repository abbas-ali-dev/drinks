import 'package:drinks/data/enums/month_names.dart';
import 'package:drinks/data/widgets/bottom_nav_bar.dart';
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
  final DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();
  final List<String> drinkIcons = ['🍸', '🍷', '🍺'];
  final List<String> drinkTypes = ['drink', 'wine', 'beer'];
  late final Box<Drink> _drinksBox;

  // Variables to store drink counts for different months
  int totalDrinksForMonth = 0;
  int totalBeersForMonth = 0;
  int totalLiquorForMonth = 0;
  int totalWineForMonth = 0;

  int totalDrinksForDoublePreviousMonth = 0;
  int totalBeersForDoublePreviousMonth = 0;
  int totalLiquorForDoublePreviousMonth = 0;
  int totalWineForDoublePreviousMonth = 0;

  int totalDrinksForPreviousMonth = 0;
  int totalBeersForPreviousMonth = 0;
  int totalLiquorForPreviousMonth = 0;
  int totalWineForPreviousMonth = 0;

  int totalDrinksForNextMonth = 0;
  int totalBeersForNextMonth = 0;
  int totalLiquorForNextMonth = 0;
  int totalWineForNextMonth = 0;

  String doublepreviousMonthName = '';
  int doublepreviousMonthYear = 0;

  String previousMonthName = '';
  int previousMonthYear = 0;

  String nextMonthName = '';
  int nextMonthYear = 0;

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
    // Reset counts for all months
    _resetDrinkCounts();

    // Calculate for previous, current, and next months
    _calculateDrinkCountsForMonth(
        DateTime(monthDate.year, monthDate.month - 1, monthDate.day),
        isPreviousMonth: true);
    _calculateDrinkCountsForMonth(monthDate);
    _calculateDrinkCountsForMonth(
        DateTime(monthDate.year, monthDate.month + 1, monthDate.day),
        isNextMonth: true);

    // Update month and year for display
    doublepreviousMonthName = DateTime(monthDate.year, monthDate.month - 2)
        .monthName(); // Correct month name calculation
    doublepreviousMonthYear =
        DateTime(monthDate.year, monthDate.month - 2).year;

    // Update month and year for display
    previousMonthName = DateTime(monthDate.year, monthDate.month - 1)
        .monthName(); // Correct month name calculation
    previousMonthYear = DateTime(monthDate.year, monthDate.month - 1).year;

    nextMonthName = DateTime(monthDate.year, monthDate.month + 1).monthName();
    nextMonthYear = DateTime(monthDate.year, monthDate.month + 1).year;
  }

  void _resetDrinkCounts() {
    totalDrinksForMonth = 0;
    totalBeersForMonth = 0;
    totalLiquorForMonth = 0;
    totalWineForMonth = 0;

    totalDrinksForDoublePreviousMonth = 0;
    totalBeersForDoublePreviousMonth = 0;
    totalLiquorForDoublePreviousMonth = 0;
    totalWineForDoublePreviousMonth = 0;

    totalDrinksForPreviousMonth = 0;
    totalBeersForPreviousMonth = 0;
    totalLiquorForPreviousMonth = 0;
    totalWineForPreviousMonth = 0;

    totalDrinksForNextMonth = 0;
    totalBeersForNextMonth = 0;
    totalLiquorForNextMonth = 0;
    totalWineForNextMonth = 0;
  }

  void _calculateDrinkCountsForMonth(DateTime monthDate,
      {bool isPreviousMonth = false, bool isNextMonth = false}) {
    for (var drink in _drinksBox.values) {
      if (drink.dateTime.year == monthDate.year &&
          drink.dateTime.month == monthDate.month) {
        if (isPreviousMonth) {
          if (drink.drinkType == 'beer') {
            totalBeersForPreviousMonth++;
          } else if (drink.drinkType == 'drink') {
            totalLiquorForPreviousMonth++;
          } else if (drink.drinkType == 'wine') {
            totalWineForPreviousMonth++;
          }
          totalDrinksForPreviousMonth++;
        } else if (isNextMonth) {
          if (drink.drinkType == 'beer') {
            totalBeersForNextMonth++;
          } else if (drink.drinkType == 'drink') {
            totalLiquorForNextMonth++;
          } else if (drink.drinkType == 'wine') {
            totalWineForNextMonth++;
          }
          totalDrinksForNextMonth++;
        } else {
          // This is for the current month
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
            size: 40,
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
            icon: const Icon(Icons.arrow_forward, size: 40),
            onPressed: _currentDate.isBefore(DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    DateTime.now().weekday))
                ? _goToNextMonth
                : null,
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //  doublePrevious Month Section
            _buildMonthSummarySection(
              monthName: doublepreviousMonthName,
              monthYear: doublepreviousMonthYear,
              totalDrinks: totalDrinksForDoublePreviousMonth,
              totalBeers: totalBeersForDoublePreviousMonth,
              totalLiquor: totalLiquorForDoublePreviousMonth,
              totalWine: totalWineForDoublePreviousMonth,
            ),

            // Next Month Section
            _buildMonthSummarySection(
              monthName: previousMonthName,
              monthYear: previousMonthYear,
              totalDrinks: totalDrinksForPreviousMonth,
              totalBeers: totalBeersForPreviousMonth,
              totalLiquor: totalLiquorForPreviousMonth,
              totalWine: totalWineForPreviousMonth,
            ),

            // Current Month Section
            _buildMonthSummarySection(
              monthName: monthDate.monthName(),
              monthYear: monthDate.year,
              totalDrinks: totalDrinksForMonth,
              totalBeers: totalBeersForMonth,
              totalLiquor: totalLiquorForMonth,
              totalWine: totalWineForMonth,
              showCalendar: true,
              dailyDrinkCounts: dailyDrinkCounts,
              daysInMonth: daysInMonth,
              offset: offset,
              monthDate: monthDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSummarySection({
    required String monthName,
    required int monthYear,
    required int totalDrinks,
    required int totalBeers,
    required int totalLiquor,
    required int totalWine,
    bool showCalendar = false,
    Map<int, int>? dailyDrinkCounts,
    int? daysInMonth,
    int? offset,
    DateTime? monthDate,
  }) {
    return Column(
      children: [
        Text(
          '$monthName $monthYear',
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 5),
        if (showCalendar)
          Column(
            children: [
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
              SizedBox(
                // Provide a fixed height to the GridView
                height: 210, // Adjust the height as needed
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.7,
                  ),
                  itemBuilder: (context, dayIndex) {
                    // Apply the offset to align days correctly
                    int adjustedDayIndex = dayIndex + 1 - offset!;

                    DateTime day = DateTime(
                        monthDate!.year, monthDate.month, adjustedDayIndex);
                    int dayDrinkCount = dailyDrinkCounts![day.day] ?? 0;

                    return Center(
                      child: adjustedDayIndex >= 1 &&
                              adjustedDayIndex <= daysInMonth!
                          ? GestureDetector(
                              onTap: () {
                                // Check if the date is in the future
                                if (day.isAfter(DateTime.now())) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "You can't see the drinks for a future date."),
                                    ),
                                  );
                                  return;
                                }

                                // Navigate to HomePage if the date is not in the future
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                    settings: RouteSettings(
                                      arguments: day, // Pass the selected date
                                    ),
                                  ),
                                  (route) =>
                                      false, // Remove all previous routes
                                );
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
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < drinkIcons.length; i++)
              Row(
                children: [
                  Text(
                    '${i == 0 ? totalLiquor : i == 1 ? totalWine : totalBeers} ',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    drinkIcons[i],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: i == 1 ? 33 : 30,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                '$totalDrinks',
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
    );
  }
}
