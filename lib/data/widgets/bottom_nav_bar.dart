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

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
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
            icon: _isMenuOpen
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
              if (_isMenuOpen) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                  (route) => false,
                );
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
                  ),
                );
              } else {
                shareContent(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

void shareContent(BuildContext context) async {
  // Get current route name more accurately
  final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

  final box = Hive.box<Drink>('drinksBox');
  String content = "Happy Hour\n";

  // Check if we're on MonthlyPage
  if (currentRoute.contains('MonthlyPage')) {
    final today = DateTime.now();
    final monthlyDrinks = box.values
        .where((drink) =>
            drink.dateTime.year == today.year &&
            drink.dateTime.month == today.month)
        .toList();

    int beerCount =
        monthlyDrinks.where((drink) => drink.drinkType == 'beer').length;
    int wineCount =
        monthlyDrinks.where((drink) => drink.drinkType == 'wine').length;
    int liquorCount =
        monthlyDrinks.where((drink) => drink.drinkType == 'drink').length;

    content += "${DateFormat('MMMM yyyy').format(today)}\n\n";
    if (liquorCount > 0) content += "🍸 - $liquorCount\n";
    if (wineCount > 0) content += "🍷 - $wineCount\n";
    if (beerCount > 0) content += "🍺 - $beerCount\n";
  }
  // Check if we're on StatsPage
  else if (currentRoute.contains('StatsPage')) {
    final allDrinks = box.values.toList();

    int beerCount =
        allDrinks.where((drink) => drink.drinkType == 'beer').length;
    int wineCount =
        allDrinks.where((drink) => drink.drinkType == 'wine').length;
    int liquorCount =
        allDrinks.where((drink) => drink.drinkType == 'drink').length;

    content += "All Time Stats\n\n";
    if (liquorCount > 0) content += "🍸 - $liquorCount\n";
    if (wineCount > 0) content += "🍷 - $wineCount\n";
    if (beerCount > 0) content += "🍺 - $beerCount\n";
  }

  // Generate Branch.io link
  BranchUniversalObject buo = BranchUniversalObject(
    canonicalIdentifier: 'flutter/branch',
    title: 'Happy Hour App',
    // contentDescription: 'Check out my monthly drinks!',
    publiclyIndex: true,
    locallyIndex: true,
  );

  BranchLinkProperties linkProperties = BranchLinkProperties(
    channel: 'app',
    feature: 'share',
    campaign: 'flutter_share',
  );

  BranchResponse response = await FlutterBranchSdk.getShortUrl(
    buo: buo,
    linkProperties: linkProperties,
  );

  if (response.success) {
    content += "\n${response.result}";
    Share.share(
      content,
    );
  }
}
