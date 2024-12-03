import 'package:drinks/global/global_variable.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:drinks/view/screens/settings_page.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class CustomBottumNavigationBar extends StatefulWidget {
  const CustomBottumNavigationBar({super.key});

  @override
  State<CustomBottumNavigationBar> createState() =>
      _CustomBottumNavigationBarState();
}

class _CustomBottumNavigationBarState extends State<CustomBottumNavigationBar> {
  bool _isMenuOpen = false;

////////////////////shareContent/////////////
  void shareContent() async {
    final box = Hive.box<Drink>('drinksBox');
    List<Drink> drinksToShare;
    String timeTitle;

    // Get the current context's widget
    final currentWidget = ModalRoute.of(context)?.settings.name ??
        context.widget.runtimeType.toString();

    if (currentWidget.contains('StatsPage')) {
      if (isAllTimeViewNotifier.value) {
        drinksToShare = box.values.toList(); // Get all drinks
        timeTitle = "All-Time";
      } else {
        final selectedYear = selectedStatsYearNotifier.value;
        drinksToShare = box.values
            .where((drink) => drink.dateTime.year == selectedYear)
            .toList();
        timeTitle = "$selectedYear";
      }
    } else if (currentWidget.contains('MonthlyPage')) {
      DateTime selectedMonth = selectedMonthNotifier.value;
      drinksToShare = box.values
          .where((drink) =>
              drink.dateTime.year == selectedMonth.year &&
              drink.dateTime.month == selectedMonth.month)
          .toList();
      timeTitle = DateFormat('MMM yyyy').format(selectedMonth);
    } else {
      final currentDate = DateTime.now();
      drinksToShare = box.values
          .where((drink) =>
              drink.dateTime.year == currentDate.year &&
              drink.dateTime.month == currentDate.month)
          .toList();
      timeTitle = DateFormat('MMM yyyy').format(currentDate);
    }

    Map<String, int> drinkCounts = {
      'wine': 0,
      'drink': 0,
      'beer': 0,
    };

    for (var drink in drinksToShare) {
      drinkCounts[drink.drinkType] = drinkCounts[drink.drinkType]! + 1;
    }

    var sortedDrinks = drinkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String content = "Happy Hour\n";
    content += "$timeTitle\n";
    content += drinksToShare.length == 1
        ? "${drinksToShare.length} drink\n"
        : "${drinksToShare.length} drinks\n";

    // New format for drink counts
    for (var drink in sortedDrinks) {
      if (drink.value > 0) {
        String emoji = drink.key == 'wine'
            ? '🍷'
            : drink.key == 'drink'
                ? '🍸'
                : '🍺';
        content += "$emoji - ${drink.value}\n";
      }
    }

    // Get Branch link and append
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'happyHourApp',
      title: 'Happy Hour',
      publiclyIndex: true,
      locallyIndex: true,
    );

    BranchLinkProperties linkProperties = BranchLinkProperties(
        channel: 'app', feature: 'share', campaign: 'happyHourApp');

    linkProperties.addControlParam('\$deeplink_path', 'happyHourApp');
    linkProperties.addControlParam('\$android_deeplink_path', 'happyHourApp');
    linkProperties.addControlParam('\$ios_deeplink_path', 'happyHourApp');
    linkProperties.addControlParam(
        '\$desktop_deeplink_path', 'https://xfnef.app.link/happyHourApp');

    BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: linkProperties,
    ); // if (response.success) {
    //   final generatedLink = response.result;
    //   content += generatedLink;
    //   Share.share(content);
    // } else {
    //   print('Error: ${response.errorMessage}');
    // }

    content += "http://xfnef.app.link/happyHourApp";
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isMenuOpenNotifier,
      builder: (context, bool isOpen, _) {
        return BottomAppBar(
          color: Colors.grey[800],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  isOpen ? Icons.calendar_month : Icons.menu,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  if (isOpen) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthlyPage(),
                        settings: const RouteSettings(name: 'MonthlyPage'),
                      ),
                    );
                    setState(() {
                      isMenuOpenNotifier.value = false;
                    });
                  } else {
                    setState(() {
                      isMenuOpenNotifier.value = true;
                    });
                  }
                },
              ),
              IconButton(
                icon: isOpen
                    ? const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 40,
                      )
                    : Image.asset(
                        "assets/png/home.png",
                        width: 40,
                        height: 40,
                        color: Colors.white,
                      ),
                onPressed: () {
                  if (isOpen) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                        settings: const RouteSettings(name: 'SettingsPage'),
                      ),
                    );
                    setState(() {
                      isMenuOpenNotifier.value = false;
                    });
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                      (route) => false,
                    );
                    setState(() {
                      isMenuOpenNotifier.value = false;
                    });
                  }
                },
              ),
              IconButton(
                icon: isOpen
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
                  if (isOpen) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatsPage(),
                        settings: const RouteSettings(name: 'StatsPage'),
                      ),
                      (route) => false,
                    );
                    setState(() {
                      isMenuOpenNotifier.value = false;
                    });
                  } else {
                    shareContent();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
