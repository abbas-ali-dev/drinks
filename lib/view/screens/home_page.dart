import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List totalDrinks = [
    {"name": "beer", "image": Image.asset("assets/png/beer.png")},
    {"name": "drink", "image": Image.asset("assets/png/drink.png")},
    {"name": "wine", "image": Image.asset("assets/png/wine.png")},
  ];
  int? selectedDrinkIndex;
  final ScrollController _scrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _drinksForSelectedDate = [];

  @override
  void initState() {
    super.initState();
    _loadDrinksForDate(_selectedDate);
  }

  void _loadDrinksForDate(DateTime date) {
    final box = Hive.box<Drink>('drinksBox');
    final drinksFromHive = box.values.where((drink) {
      return drink.dateTime.year == date.year &&
          drink.dateTime.month == date.month &&
          drink.dateTime.day == date.day;
    }).toList();

    setState(() {
      _drinksForSelectedDate = drinksFromHive.map((drink) {
        return {
          'type': drink.drinkType,
          'time': DateFormat.jm().format(drink.dateTime),
        };
      }).toList();
    });
  }

  void _addDrink() {
    setState(() {
      if (selectedDrinkIndex != null) {
        final newDrink = Drink(
          dateTime: DateTime.now(),
          drinkType: totalDrinks[selectedDrinkIndex!]["name"],
        );

        // Add to Hive box
        final box = Hive.box<Drink>('drinksBox');
        box.add(newDrink);

        // Reload drinks for the current date
        _loadDrinksForDate(_selectedDate);

        // Scroll to the bottom after adding the drink
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    });
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _loadDrinksForDate(_selectedDate);
    });
  }

  void _goToNextDay() {
    if (_selectedDate.isBefore(DateTime.now())) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        _loadDrinksForDate(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE').format(_selectedDate),
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(_selectedDate),
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: _goToPreviousDay,
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed:
                _selectedDate.isBefore(DateTime.now()) ? _goToNextDay : null,
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.grey[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 25.w, top: 1.h),
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _drinksForSelectedDate.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: ListTile(
                        leading: _drinksForSelectedDate[index]['type'] ==
                                'drink'
                            ? Image.asset("assets/png/drink.png")
                            : _drinksForSelectedDate[index]['type'] == 'beer'
                                ? Image.asset("assets/png/beer.png")
                                : _drinksForSelectedDate[index]['type'] ==
                                        'wine'
                                    ? Image.asset("assets/png/wine.png")
                                    : const SizedBox.shrink(),
                        title: Text(
                          _drinksForSelectedDate[index]['time'],
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.white,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '${_drinksForSelectedDate.length} Drinks',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 10.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: totalDrinks.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDrinkIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedDrinkIndex == index
                                ? Colors.white
                                : Colors.transparent,
                            width: 0.9.w,
                          ),
                        ),
                        child: totalDrinks[index]["image"],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MonthlyPage(),
                    ));
              },
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _addDrink,
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
