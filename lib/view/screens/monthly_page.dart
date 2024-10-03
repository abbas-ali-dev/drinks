import 'package:drinks/data/enums/month_names.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({super.key});

  @override
  _MonthlyPageState createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  final ScrollController _scrollController = ScrollController();
  final DateTime _initialDate = DateTime(2023, 12);
  DateTime _currentDate = DateTime(2023, 12);
  final double _itemHeight = 450.0;
  final List<String> drinks = ['🍸', '🍷', '🍺'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
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
      });
    }
  }

  List<int> generateRandomDrinks() {
    Random random = Random();
    return List<int>.generate(
        3, (_) => random.nextInt(10) + 1); // 3 random drink counts
  }

  List<int> generateRandomSpecialDays(int maxDays) {
    Random random = Random();
    int numSpecialDays =
        random.nextInt(3) + 1; // Random number of special days (1-3)
    Set<int> specialDays = {};
    while (specialDays.length < numSpecialDays) {
      specialDays.add(
          random.nextInt(maxDays) + 1); // Ensure days are within month range
    }
    return specialDays.toList();
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
        title: Text(
          '${_currentDate.monthName()}\n    ${_currentDate.year}',
          style: const TextStyle(
              color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
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
            List<int> drinkCounts = generateRandomDrinks();
            int totalDrinks = drinkCounts.reduce((a, b) => a + b);

            int daysInMonth =
                DateTime(monthDate.year, monthDate.month + 1, 0).day;
            List<int> specialDays = generateRandomSpecialDays(daysInMonth);

            return SizedBox(
              height: 390,
              // height: _itemHeight,
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
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Check if the day is a special day
                                      if (specialDays.contains(day.day))
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
                                        )
                                    ],
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
                        for (int i = 0; i < drinkCounts.length; i++)
                          Row(
                            children: [
                              Text(' ${drinkCounts[i]} ',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                              Text(drinks[i],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        const Text(
                          " = ",
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
