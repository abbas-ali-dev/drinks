import 'package:drinks/data/enums/month_names.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({super.key});

  @override
  _MonthlyPageState createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  final ScrollController _scrollController = ScrollController();
  final DateTime _initialDate = DateTime(2024, 1);
  DateTime _currentDate = DateTime(2024, 1);
  final double _itemHeight = 450.0;
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
    _scrollController.addListener(_scrollListener);
    _drinksBox = Hive.box<Drink>('drinksBox');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
      _calculateMonthlyDrinkCounts(_currentDate); // Calculate for initial month
    });
  }

  void _scrollListener() {
    double scrollOffset = _scrollController.offset;
    int monthOffset = (scrollOffset / _itemHeight).floor();
    DateTime newDate =
        DateTime(_initialDate.year, _initialDate.month + monthOffset);

    // Only update the date if it changes
    if (newDate != _currentDate) {
      setState(() {
        _currentDate = newDate;
        _calculateMonthlyDrinkCounts(_currentDate); // Calculate for new month
      });
    }
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

    // setState(() {}); // Update the UI
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
            Navigator.pop(context);
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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatsPage(),
                  ));
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.grey[800],
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) {
            DateTime monthDate =
                DateTime(_initialDate.year, _initialDate.month + index);
            int daysInMonth =
                DateTime(monthDate.year, monthDate.month + 1, 0).day;

            // Calculate monthly drink counts for the current monthDate
            _calculateMonthlyDrinkCounts(monthDate);

            return SizedBox(
              height: 390,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
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
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Mon',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Tue',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Wed',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Thu',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Fri',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Sat',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Flexible(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.7,
                        ),
                        itemBuilder: (context, dayIndex) {
                          DateTime day = DateTime(
                              monthDate.year, monthDate.month, dayIndex + 1);

                          return Center(
                            child: dayIndex < daysInMonth
                                ? GestureDetector(
                                    onTap: () {
                                      // Handle day tap (e.g., show details)
                                      print('Tapped on: $day');
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Circle indicator for drinks
                                        if (_hasDrinks(day))
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${day.day}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else
                                          Text(
                                            '${day.day}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
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
          },
          itemCount:
              120, // Display enough months for testing scrolling (10 years)
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
              onPressed: () {},
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
