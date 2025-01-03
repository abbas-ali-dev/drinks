import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drinks/data/widgets/analogClockDialog.dart';
import 'package:drinks/data/widgets/drink_selection_dialog.dart';
import 'package:drinks/global/global_variable.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/services/adMob.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:drinks/view/screens/settings_page.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  BannerAd? _bannerAd;
  List totalDrinks = [
    {"name": "drink", "image": Image.asset("assets/png/drink.png")},
    {"name": "wine", "image": Image.asset("assets/png/wine.png")},
    {"name": "beer", "image": Image.asset("assets/png/beer.png")},
  ];
  int? selectedDrinkIndex;
  final ScrollController _scrollController = ScrollController();
  bool _isMenuOpen = false;
  bool _showNotes = false;
  bool _showDrinksPerHour = false;

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _drinksForSelectedDate = [];

  bool _showDrinkSelection = false;

  @override
  void initState() {
    super.initState();
    checkConectivity();
    if (showAdMobGlobally.value == true) {
      _bannerAd = AdHelper.createBannerAd(() {
        setState(() {});
      });
    }

    // Initialize with current date adjusted for cutoff time
    _selectedDate = _getInitialDate();
    _loadDrinksForDate(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  DateTime _getInitialDate() {
    DateTime now = DateTime.now();
    int cutoffHour = getCutoffHour();
    int cutoffMinutes = getCutoffMinutes();

    DateTime todayCutoff = DateTime(
      now.year,
      now.month,
      now.day,
      cutoffHour,
      cutoffMinutes,
    );

    if (now.hour < cutoffHour ||
        (now.hour == cutoffHour && now.minute < cutoffMinutes)) {
      todayCutoff = todayCutoff.subtract(const Duration(days: 1));
    }

    return todayCutoff;
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

  // Helper function to parse cutoff time
  int getCutoffHour() {
    String timeStr = selectedCutoffTimeGlobally;
    List<String> timeParts = timeStr.split(':');
    return int.parse(timeParts[0]);
  }

  int getCutoffMinutes() {
    String timeStr = selectedCutoffTimeGlobally;
    List<String> timeParts = timeStr.split(':');
    // Extract just the minutes by removing AM/PM and spaces
    String minuteStr = timeParts[1].split(' ')[0];
    return int.parse(minuteStr);
  }

  void _addDrink() {
    setState(() {
      if (selectedDrinkIndex != null) {
        DateTime now = DateTime.now();
        DateTime drinkDateTime;

        // Get adjusted current date based on cutoff time
        DateTime adjustedNow = getAdjustedDate(now);
        DateTime adjustedSelectedDate = getAdjustedDate(_selectedDate);

        // Check if selected date is before adjusted current date
        bool isPreviousDate = adjustedSelectedDate.isBefore(adjustedNow);

        if (isPreviousDate) {
          if (_drinksForSelectedDate.isEmpty) {
            // For previous date with no drinks, set to 6:00 PM
            drinkDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              18, // 6 PM
              0,
            );
          } else {
            // Add 1 hour after the last drink
            DateTime lastDrinkTime = _drinksForSelectedDate.last['dateTime'];
            drinkDateTime = lastDrinkTime.add(const Duration(hours: 1));
          }
        } else {
          // Current date - keep existing cutoff time logic
          int cutoffHour = getCutoffHour();
          int cutoffMinutes = getCutoffMinutes();

          drinkDateTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            now.hour,
            now.minute,
          );

          if (now.hour < cutoffHour ||
              (now.hour == cutoffHour && now.minute < cutoffMinutes)) {
            drinkDateTime = drinkDateTime.add(const Duration(days: 1));
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
          scrollToBottom();
        });

        _showDrinkSelection = false;
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
    DateTime now = DateTime.now();
    DateTime adjustedNow = getAdjustedDate(now);
    DateTime adjustedSelected = getAdjustedDate(_selectedDate);

    if (adjustedSelected.isBefore(adjustedNow)) {
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      // Create DateTime with noon time to avoid cutoff time adjustments
      DateTime adjustedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        12, // Set to noon
        0,
      );

      setState(() {
        _selectedDate = adjustedDate;
        _loadDrinksForDate(adjustedDate);
      });
    }
  }

  DateTime? _initialDateFromArgs; // Store initial date from route arguments

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is DateTime && _initialDateFromArgs == null) {
      // Only set if _initialDateFromArgs is null. It means this is the initial page load from MonthlyPage
      _initialDateFromArgs = arguments; // Store initial date separately

      DateTime adjustedDate = DateTime(
        arguments.year,
        arguments.month,
        arguments.day,
        12, // Set to noon
      );
      setState(() {
        _selectedDate = adjustedDate;
      });
      _loadDrinksForDate(_selectedDate); //Load only once
    }
  }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)?.settings.arguments;
  //   if (arguments is DateTime) {
  //     // Create a new DateTime object with noon time to ensure consistent date handling
  //     DateTime adjustedDate = DateTime(
  //       arguments.year,
  //       arguments.month,
  //       arguments.day,
  //       12, // Set to noon
  //     );

  //     setState(() {
  //       _selectedDate = adjustedDate;
  //     });
  //     _loadDrinksForDate(_selectedDate);
  //   }
  // }

  Future<void> _showDrinkChangeDialog(int index) async {
    final box = Hive.box<Drink>('drinksBox');
    final currentDrink = _drinksForSelectedDate[index];
    final allDrinks = box.values.toList();

    final drinkIndex = allDrinks.indexWhere((drink) =>
        drink.dateTime == currentDrink['dateTime'] &&
        drink.drinkType == currentDrink['type']);

    await showDialog(
      context: context,
      builder: (context) => DrinkSelectionDialog(
        currentDrink: Drink(
          dateTime: currentDrink['dateTime'],
          drinkType: currentDrink['type'],
          note: currentDrink['note'],
        ),
        onDrinkSelected: (newDrink) {
          if (drinkIndex != -1) {
            box.putAt(drinkIndex, newDrink);
            _loadDrinksForDate(_selectedDate);
          }
        },
        onDeleteDrink: () {
          if (drinkIndex != -1) {
            box.deleteAt(drinkIndex);
            _loadDrinksForDate(_selectedDate);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _loadDrinksForDate(DateTime date) {
    final box = Hive.box<Drink>('drinksBox');

    int cutoffHour = getCutoffHour();
    int cutoffMinutes = getCutoffMinutes();

    // Start time is cutoff time of selected date
    DateTime startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      cutoffHour,
      cutoffMinutes,
    );

    // End time is cutoff time of next date
    DateTime endDateTime = startDateTime.add(const Duration(days: 1));

    final drinksFromHive = box.values.where((drink) {
      return drink.dateTime.isAtSameMomentAs(
              startDateTime) || // Include drinks at the exact cutoff time
          (drink.dateTime.isAfter(startDateTime) &&
              drink.dateTime.isBefore(endDateTime));
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

      _drinksForSelectedDate.sort((a, b) =>
          (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
    });
  }

  // Future<void> _showTimePicker(int index) async {
  //   if (_drinksForSelectedDate.isEmpty ||
  //       index >= _drinksForSelectedDate.length) return;

  //   final currentDrink = _drinksForSelectedDate[index];
  //   final DateTime originalDateTime = currentDrink['dateTime'];

  //   await showDialog<TimeOfDay>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AnalogClockDialog(
  //         initialTime: originalDateTime,
  //         onTimeSelected: (DateTime newTime) {
  //           final box = Hive.box<Drink>('drinksBox');
  //           final allDrinks = box.values.toList();

  //           final drinkIndex = allDrinks.indexWhere((drink) =>
  //               drink.dateTime == currentDrink['dateTime'] &&
  //               drink.drinkType == currentDrink['type']);

  //           if (drinkIndex != -1) {
  //             final oldDrink = box.getAt(drinkIndex);
  //             if (oldDrink != null) {
  //               int cutoffHour = getCutoffHour();
  //               int cutoffMinutes = getCutoffMinutes();

  //               DateTime baseDate = _selectedDate;
  //               if (newTime.hour < cutoffHour ||
  //                   (newTime.hour == cutoffHour &&
  //                       newTime.minute < cutoffMinutes)) {
  //                 baseDate = baseDate.add(const Duration(days: 1));
  //               }

  //               final newDrink = Drink(
  //                 dateTime: DateTime(
  //                   baseDate.year,
  //                   baseDate.month,
  //                   baseDate.day,
  //                   newTime.hour,
  //                   newTime.minute,
  //                 ),
  //                 drinkType: oldDrink.drinkType,
  //                 note: oldDrink.note,
  //               );

  //               box.putAt(drinkIndex, newDrink);
  //               _loadDrinksForDate(_selectedDate);
  //             }
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> _showTimePicker(int index) async {
    await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        DateTime? dateTime = _drinksForSelectedDate[index]['dateTime'];

        return AnalogClockDialog(
          initialTime: dateTime ?? DateTime.now(),
          onTimeSelected: (DateTime newTime) {
            final box = Hive.box<Drink>('drinksBox');
            final allDrinks = box.values.toList();
            final currentDrink = _drinksForSelectedDate[index];

            final drinkIndex = allDrinks.indexWhere((drink) =>
                drink.dateTime == currentDrink['dateTime'] &&
                drink.drinkType == currentDrink['type']);

            if (drinkIndex != -1) {
              final oldDrink = box.getAt(drinkIndex);
              if (oldDrink != null) {
                int cutoffHour = getCutoffHour();
                int cutoffMinutes = getCutoffMinutes();

                // Calculate the correct date based on selected time
                DateTime baseDate = _selectedDate;
                if (newTime.hour < cutoffHour ||
                    (newTime.hour == cutoffHour &&
                        newTime.minute < cutoffMinutes)) {
                  baseDate = baseDate.add(const Duration(days: 1));
                }

                final newDrink = Drink(
                  dateTime: DateTime(
                    baseDate.year,
                    baseDate.month,
                    baseDate.day,
                    newTime.hour,
                    newTime.minute,
                  ),
                  drinkType: oldDrink.drinkType,
                  note: oldDrink.note,
                );

                box.putAt(drinkIndex, newDrink);
                _loadDrinksForDate(_selectedDate);
              }
            }
          },
        );
      },
    );
  }

  // void _loadDrinksForDate(DateTime date) {
  //   final box = Hive.box<Drink>('drinksBox');

  //   int cutoffHour = getCutoffHour();
  //   int cutoffMinutes = getCutoffMinutes();

  //   // Start time is cutoff time of selected date
  //   DateTime startDateTime = DateTime(
  //     date.year,
  //     date.month,
  //     date.day,
  //     cutoffHour,
  //     cutoffMinutes,
  //   );

  //   // End time is cutoff time of next date
  //   DateTime endDateTime = startDateTime.add(const Duration(days: 1));

  //   final drinksFromHive = box.values.where((drink) {
  //     return drink.dateTime.isAfter(startDateTime) &&
  //         drink.dateTime.isBefore(endDateTime);
  //   }).toList();

  //   setState(() {
  //     _drinksForSelectedDate = drinksFromHive.map((drink) {
  //       return {
  //         'type': drink.drinkType,
  //         'time': selectedTimeFormatGlobally == '12 Hour'
  //             ? DateFormat.jm().format(drink.dateTime.toLocal())
  //             : DateFormat('HH:mm').format(drink.dateTime),
  //         'dateTime': drink.dateTime,
  //         'note': drink.note,
  //       };
  //     }).toList();

  //     _drinksForSelectedDate.sort((a, b) =>
  //         (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
  //   });
  // }

  // Future<void> _showTimePicker(int index) async {
  //   await showDialog<TimeOfDay>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       DateTime? dateTime = _drinksForSelectedDate[index]['dateTime'];

  //       return AnalogClockDialog(
  //         initialTime: dateTime ?? DateTime.now(),
  //         onTimeSelected: (DateTime newTime) {
  //           final box = Hive.box<Drink>('drinksBox');
  //           final allDrinks = box.values.toList();
  //           final currentDrink = _drinksForSelectedDate[index];

  //           final drinkIndex = allDrinks.indexWhere((drink) =>
  //               drink.dateTime == currentDrink['dateTime'] &&
  //               drink.drinkType == currentDrink['type']);

  //           if (drinkIndex != -1) {
  //             final oldDrink = box.getAt(drinkIndex);
  //             if (oldDrink != null) {
  //               final originalDate = currentDrink['dateTime'] as DateTime;

  //               final newDrink = Drink(
  //                 dateTime: DateTime(
  //                   originalDate.year,
  //                   originalDate.month,
  //                   originalDate.day,
  //                   newTime.hour,
  //                   newTime.minute,
  //                 ),
  //                 drinkType: oldDrink.drinkType,
  //                 note: oldDrink.note,
  //               );
  //               print("New Drinkss: ${newDrink.dateTime}");
  //               box.putAt(drinkIndex, newDrink);
  //               _loadDrinksForDate(_selectedDate);
  //             }
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

  String _calculateDrinksPerHour() {
    if (_drinksForSelectedDate.isEmpty) return '0.0';

    // Check if it's current date
    if (_selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day) {
      final firstDrinkTime =
          _drinksForSelectedDate.first['dateTime'] as DateTime;
      final lastDrinkTime = _drinksForSelectedDate.last['dateTime'] as DateTime;

      // Calculate time difference in hours for current date
      final timeDifference = lastDrinkTime.difference(firstDrinkTime).inHours;

      // If time difference is 0 hours, return 1.0 to avoid division by zero
      if (timeDifference == 0) return '1.0';

      return timeDifference.toStringAsFixed(1);
    } else {
      // For past dates, return total drinks
      return _drinksForSelectedDate.length.toStringAsFixed(1);
    }
  }

  List<Map<String, dynamic>> _groupDrinksByNote(
      List<Map<String, dynamic>> drinks) {
    Map<String?, List<Map<String, dynamic>>> groupedDrinks = {};

    for (var drink in drinks) {
      String? note = drink['note'];
      if (!groupedDrinks.containsKey(note)) {
        groupedDrinks[note] = [];
      }
      groupedDrinks[note]!.add(drink);
    }

    List<Map<String, dynamic>> result = [];
    groupedDrinks.forEach((note, drinks) {
      if (drinks.length == 1) {
        result.add(drinks.first);
      } else {
        result.add({
          'type': 'group',
          'drinks': drinks,
          'note': note,
        });
      }
    });

    return result;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
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

        if (_showDrinkSelection) {
          setState(() {
            _showDrinkSelection = false;
          });
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            AdHelper.getBannerAdWidget(_bannerAd),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEEE')
                              .format(getAdjustedDate(_selectedDate)),
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy')
                              .format(getAdjustedDate(_selectedDate)),
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: _goToPreviousDay,
                    ),
                  ),
                  actions: [
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_forward_ios, size: 40),
                      onPressed: DateTime.now().isAfter(
                              getAdjustedDate(_selectedDate)
                                  .add(const Duration(days: 1)))
                          ? _goToNextDay
                          : null,
                    ),
                  ],
                  centerTitle: true,
                  backgroundColor: const Color.fromARGB(255, 53, 53, 53),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isMenuOpen = false;
                              _showDrinkSelection = false;
                            });
                          },
                          onHorizontalDragEnd: (DragEndDetails details) {
                            // Check if any drinks have notes
                            bool hasNotes = _drinksForSelectedDate.any(
                                (drink) =>
                                    drink['note'] != null &&
                                    drink['note'].toString().isNotEmpty);

                            if (details.primaryVelocity! < 0 && hasNotes) {
                              // Only toggle notes if there are drinks with notes
                              setState(() {
                                _showNotes = !_showNotes;
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: selectedTimeFormatGlobally == '24 Hour'
                                  ? 29.w
                                  : 26.w,
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: _drinksForSelectedDate.length,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: ListTile(
                                    leading: GestureDetector(
                                      onTap: () =>
                                          _showDrinkChangeDialog(index),
                                      child: _drinksForSelectedDate[index]
                                                  ['type'] ==
                                              'drink'
                                          ? Image.asset("assets/png/drink.png")
                                          : _drinksForSelectedDate[index]
                                                      ['type'] ==
                                                  'beer'
                                              ? Image.asset(
                                                  "assets/png/beer.png")
                                              : _drinksForSelectedDate[index]
                                                          ['type'] ==
                                                      'wine'
                                                  ? Image.asset(
                                                      "assets/png/wine.png")
                                                  : const SizedBox.shrink(),
                                    ),
                                    title: GestureDetector(
                                      onTap: () => _showTimePicker(index),
                                      child: Text(
                                        _drinksForSelectedDate[index]['time'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                    subtitle: _showNotes
                                        ? Text(
                                            _drinksForSelectedDate[index]
                                                    ['note'] ??
                                                '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.white,
                        height: 3,
                      ),
                      Visibility(
                        visible: !_showDrinkSelection,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showDrinksPerHour = !_showDrinksPerHour;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              // _showDrinksPerHour
                              //     ? '${_calculateDrinksPerHour()} Drinks/Hour'
                              //     :
                              '${_drinksForSelectedDate.length} Drinks',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDrinkIndex = index;
                                            _addDrink();
                                          });
                                        },
                                        child: Container(
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
                                settings:
                                    const RouteSettings(name: 'MonthlyPage'),
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
                                settings:
                                    const RouteSettings(name: 'StatsPage'),
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
            ),
          ],
        ),
      ),
    );
  }

  void shareContent() async {
    final box = Hive.box<Drink>('drinksBox');

    int cutoffHour = getCutoffHour();
    int cutoffMinutes = getCutoffMinutes();

    // Start time is cutoff time of selected date
    DateTime startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      cutoffHour,
      cutoffMinutes,
    );

    // End time is cutoff time of next date
    DateTime endDateTime = startDateTime.add(const Duration(days: 1));

    // Get drinks using same logic as homepage
    final selectedDateDrinks = box.values.where((drink) {
      return drink.dateTime.isAtSameMomentAs(startDateTime) ||
          (drink.dateTime.isAfter(startDateTime) &&
              drink.dateTime.isBefore(endDateTime));
    }).toList();

    // Sort drinks by time
    selectedDateDrinks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    String content = "Happy Hour\n";
    content += DateFormat('E MM/dd/yy').format(_selectedDate);
    content += "\n";

    // Add drink icons with line break after every 5 drinks
    for (var i = 0; i < selectedDateDrinks.length; i++) {
      if (i > 0 && i % 5 == 0) {
        content += "\n";
      }
      content += selectedDateDrinks[i].drinkType == 'beer'
          ? '🍺'
          : selectedDateDrinks[i].drinkType == 'wine'
              ? '🍷'
              : '🍸';
    }
    if (selectedDateDrinks.isNotEmpty) {
      content += "\n";
    }

    content += "http://xfnef.app.link/happyHourApp";
    Share.share(content);
  }
}

DateTime getAdjustedDate(DateTime dateTime) {
  int cutoffHour = getCutoffHour();
  int cutoffMinutes = getCutoffMinutes();

  DateTime cutoffTime = DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    cutoffHour,
    cutoffMinutes,
  );

  if (dateTime.hour < cutoffHour ||
      (dateTime.hour == cutoffHour && dateTime.minute < cutoffMinutes)) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day - 1);
  }

  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}
