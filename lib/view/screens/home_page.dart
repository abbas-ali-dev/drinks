import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:drinks/view/screens/stats_page.dart';
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
  List<Map<String, dynamic>> drinks = [];

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

        // Update the UI list (optional, if you're displaying it)
        drinks.add({
          'type': newDrink.drinkType,
          'time': DateFormat.jm().format(newDrink.dateTime),
        });
      }
    });
  }

  // void _addDrink() {
  //   setState(() {
  //     if (selectedDrinkIndex != null) {
  //       drinks.add({
  //         'type': totalDrinks[selectedDrinkIndex!]["name"],
  //         'time': DateFormat.jm().format(DateTime.now()),
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final screensize = MediaQuery.of(context).size.width / 100 * 25;
    debugPrint("======>Screen Size: $screensize");
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE').format(DateTime.now()),
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(DateTime.now()),
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MonthlyPage(),
                  ));
            },
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
                  shrinkWrap: true,
                  itemCount: drinks.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: ListTile(
                        leading: drinks[index]['type'] == 'drink'
                            ? Image.asset("assets/png/drink.png")
                            : drinks[index]['type'] == 'beer'
                                ? Image.asset("assets/png/beer.png")
                                : drinks[index]['type'] == 'wine'
                                    ? Image.asset("assets/png/wine.png")
                                    : const SizedBox.shrink(),
                        title: Text(
                          drinks[index]['time'],
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
                '${drinks.length} Drinks',
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
              onPressed: () {},
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
