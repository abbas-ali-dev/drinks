import 'package:drinks/data/widgets/analogClockDialog.dart';
import 'package:drinks/data/widgets/drink_selection_dialog.dart';
import 'package:drinks/global/global_variable.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:drinks/view/screens/settings_page.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List totalDrinks = [
    {"name": "drink", "image": Image.asset("assets/png/drink.png")},
    {"name": "wine", "image": Image.asset("assets/png/wine.png")},
    {"name": "beer", "image": Image.asset("assets/png/beer.png")},
  ];
  int? selectedDrinkIndex;
  final ScrollController _scrollController = ScrollController();
  bool _isMenuOpen = false;

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _drinksForSelectedDate = [];

  bool _showDrinkSelection = false;

  @override
  void initState() {
    super.initState();
    _loadDrinksForDate(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _loadDrinksForDate(DateTime date) {
    final box = Hive.box<Drink>('drinksBox');
    final drinksFromHive = box.values.where((drink) {
      final adjustedDrinkDate = getAdjustedDate(drink.dateTime);
      return adjustedDrinkDate.year == date.year &&
          adjustedDrinkDate.month == date.month &&
          adjustedDrinkDate.day == date.day;
    }).toList();

    setState(() {
      _drinksForSelectedDate = drinksFromHive.map((drink) {
        return {
          'type': drink.drinkType,
          'time': selectedTimeFormatGlobally == '12 Hour'
              ? DateFormat.jm().format(drink.dateTime.toLocal())
              : DateFormat('HH:mm').format(drink.dateTime),
          'dateTime': drink.dateTime,
          'note': drink.note,
        };
      }).toList();
    });
  }

  void _addDrink() {
    setState(() {
      if (selectedDrinkIndex != null) {
        DateTime drinkDateTime;

        // Check if selected date is today
        if (_selectedDate.year == DateTime.now().year &&
            _selectedDate.month == DateTime.now().month &&
            _selectedDate.day == DateTime.now().day) {
          // For current date, use current time
          drinkDateTime = DateTime.now();
        } else {
          // For past dates, use the 6 PM or last drink + 1 hour logic
          final drinksForDay = _drinksForSelectedDate;
          if (drinksForDay.isEmpty) {
            drinkDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              18, // 6 PM
              0,
            );
          } else {
            final lastDrink = drinksForDay.last;
            final lastDrinkTime = lastDrink['dateTime'] as DateTime;
            drinkDateTime = lastDrinkTime.add(const Duration(hours: 1));
          }
        }

        final newDrink = Drink(
          dateTime: drinkDateTime,
          drinkType: totalDrinks[selectedDrinkIndex!]["name"],
        );

        final box = Hive.box<Drink>('drinksBox');
        box.add(newDrink);
        _loadDrinksForDate(_selectedDate);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        });

        _showDrinkSelection = false;
      }
    });
  }

  DateTime getAdjustedDate(DateTime drinkDateTime) {
    // Parse cutoff time from settings
    final cutoffTimeStr = selectedCutoffTimeGlobally;
    final cutoffTimeParts = cutoffTimeStr.split(':');
    final cutoffHour = int.parse(cutoffTimeParts[0]);
    final cutoffMinute = int.parse(cutoffTimeParts[1].split(' ')[0]);

    // Convert AM/PM to 24-hour format if needed
    int adjustedCutoffHour = cutoffHour;
    if (cutoffTimeStr.contains('PM') && cutoffHour != 12) {
      adjustedCutoffHour += 12;
    } else if (cutoffTimeStr.contains('AM') && cutoffHour == 12) {
      adjustedCutoffHour = 0;
    }

    // If drink time is before cutoff time, assign it to previous day
    if (drinkDateTime.hour < adjustedCutoffHour ||
        (drinkDateTime.hour == adjustedCutoffHour &&
            drinkDateTime.minute < cutoffMinute)) {
      return drinkDateTime.subtract(const Duration(days: 1));
    }

    return drinkDateTime;
  }

  // void _addDrink() {
  //   setState(() {
  //     if (selectedDrinkIndex != null) {
  //       final newDrink = Drink(
  //         dateTime: _selectedDate,
  //         drinkType: totalDrinks[selectedDrinkIndex!]["name"],
  //       );

  //       final box = Hive.box<Drink>('drinksBox');
  //       box.add(newDrink);

  //       _loadDrinksForDate(_selectedDate);

  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         _scrollController.animateTo(
  //           _scrollController.position.maxScrollExtent,
  //           duration: const Duration(milliseconds: 100),
  //           curve: Curves.easeOut,
  //         );
  //       });
  //       Future.delayed(const Duration(milliseconds: 50), () {
  //         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //       });

  //       _showDrinkSelection = false;
  //     }
  //   });
  // }

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadDrinksForDate(_selectedDate);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is DateTime) {
      setState(() {
        _selectedDate = arguments;
      });
      _loadDrinksForDate(_selectedDate);
    }
  }

  Future<void> _showDrinkChangeDialog(int index) async {
    final currentDrink = _drinksForSelectedDate[index];

    await showDialog(
      context: context,
      builder: (context) => DrinkSelectionDialog(
        currentDrink: Drink(
          dateTime: currentDrink['dateTime'],
          drinkType: currentDrink['type'],
          note: currentDrink['note'],
        ),
        onDrinkSelected: (newDrink) {
          final box = Hive.box<Drink>('drinksBox');
          box.putAt(index, newDrink);
          _loadDrinksForDate(_selectedDate);
        },
        onDeleteDrink: () {
          final box = Hive.box<Drink>('drinksBox');
          box.deleteAt(index);
          _loadDrinksForDate(_selectedDate);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showTimePicker(int index) async {
    final TimeOfDay? pickedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        DateTime? dateTime = _drinksForSelectedDate[index]['dateTime'];

        return AnalogClockDialog(
          initialTime: dateTime ?? DateTime.now(),
          onTimeSelected: (DateTime newTime) {
            final box = Hive.box<Drink>('drinksBox');
            final oldDrink = box.getAt(index);
            if (oldDrink != null) {
              final newDrink = Drink(
                dateTime: newTime,
                drinkType: oldDrink.drinkType,
                note: oldDrink.note,
              );
              box.putAt(index, newDrink);
            }
            _loadDrinksForDate(_selectedDate);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isMenuOpen) {
          setState(() {
            _isMenuOpen = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () => _selectDate(context),
            child: Column(
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
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 40,
              color: Colors.white,
            ),
            onPressed: _goToPreviousDay,
          ),
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.arrow_forward, size: 40),
              onPressed: _selectedDate.isBefore(DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day))
                  ? _goToNextDay
                  : null,
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
                  padding: EdgeInsets.only(left: 27.w, top: 1.h),
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: _drinksForSelectedDate.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () => _showDrinkChangeDialog(index),
                            child: _drinksForSelectedDate[index]['type'] ==
                                    'drink'
                                ? Image.asset("assets/png/drink.png")
                                : _drinksForSelectedDate[index]['type'] ==
                                        'beer'
                                    ? Image.asset("assets/png/beer.png")
                                    : _drinksForSelectedDate[index]['type'] ==
                                            'wine'
                                        ? Image.asset("assets/png/wine.png")
                                        : const SizedBox.shrink(),
                          ),
                          title: GestureDetector(
                            onTap: () => _showTimePicker(index),
                            child: Text(
                              _drinksForSelectedDate[index]['time'],
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                          subtitle: Text(
                            _drinksForSelectedDate[index]['note'] ?? '',
                            style: const TextStyle(color: Colors.grey),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showDrinkSelection
                    ? SizedBox(
                        height: 10.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: totalDrinks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDrinkIndex = index;
                                    _addDrink();
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
                      )
                    : const SizedBox.shrink(),
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
                icon: Icon(
                  _isMenuOpen ? Icons.calendar_month : Icons.menu,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  if (_isMenuOpen) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthlyPage(),
                        settings: const RouteSettings(name: 'MonthlyPage'),
                      ),
                    );
                  } else {
                    setState(() {
                      _isMenuOpen = true;
                    });
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  _isMenuOpen ? Icons.settings : Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  if (_isMenuOpen) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  } else {
                    setState(() {
                      _showDrinkSelection = !_showDrinkSelection;
                    });
                  }
                },
              ),
              IconButton(
                icon: _isMenuOpen
                    ? Image.asset(
                        "assets/png/stats.png",
                        width: 40,
                        height: 40,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.near_me_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                onPressed: () {
                  if (_isMenuOpen) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatsPage(),
                        settings: const RouteSettings(name: 'StatsPage'),
                      ),
                    );
                  } else {
                    shareContent();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void shareContent() async {
    // 1. Get today's drinks from Hive
    final box = Hive.box<Drink>('drinksBox');
    final today = DateTime.now();
    final todaysDrinks = box.values
        .where((drink) =>
            drink.dateTime.year == today.year &&
            drink.dateTime.month == today.month &&
            drink.dateTime.day == today.day)
        .toList();

    // 2. Create the formatted content string
    String content = "Happy Hour\n";
    // content += "${DateFormat('EEE MM/dd/yy').format(today)}\n";
    content += DateFormat('EEE dd/MM/yy').format(today);
    content += "\n";
    // Add drink icons to the content
    for (var drink in todaysDrinks) {
      content += drink.drinkType == 'beer'
          ? '🍺'
          : drink.drinkType == 'wine'
              ? '🍷'
              : '🍸';
    }
    content += "\n"; // Add a newline after the drink icons

    // 3. Generate the Branch.io link
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      title: 'Happy Hour App',
      contentDescription: 'Check out my cool drinks!',
      publiclyIndex: true,
      locallyIndex: true,
    );

    BranchLinkProperties linkProperties = BranchLinkProperties(
      channel: 'app',
      feature: 'share',
      campaign: 'flutter_share',
    );

    linkProperties.addControlParam('\$desktop_url', 'https://myapp.com');

    BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: linkProperties,
    );

    if (response.success) {
      final generatedLink = response.result;
      content += generatedLink; // Add the link to the content

      // 4. Share the content
      Share.share(content, subject: 'Check out my Happy Hour!');
    } else {
      print('Error: ${response.errorMessage}');
    }
  }
}
