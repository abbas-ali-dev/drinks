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
  final currentDate0 = DateTime.now();
  final box = Hive.box<Drink>('drinksBox');
  List<Drink> drinksToShare;
  String timeTitle;

  // Check current route name to determine which screen we're on
  final currentRoute = ModalRoute.of(context)?.settings.name;

  if (currentRoute == 'StatsPage') {
    drinksToShare = box.values.toList();
    timeTitle = "All Time";
  } else {
    final currentDate = currentDate0;
    drinksToShare = box.values
        .where((drink) =>
            drink.dateTime.year == currentDate.year &&
            drink.dateTime.month == currentDate.month)
        .toList();
    timeTitle = DateFormat('MMMM yyyy').format(currentDate);
  }

  String content = "Happy Hour\n\n";
  content += "$timeTitle\n\n";
  content += "${drinksToShare.length} drinks\n\n";

  // Add drink icons with line break after every 5 drinks
  for (var i = 0; i < drinksToShare.length; i++) {
    if (i > 0 && i % 5 == 0) {
      content += "\n";
    }
    content += drinksToShare[i].drinkType == 'beer'
        ? '🍺'
        : drinksToShare[i].drinkType == 'wine'
            ? '🍷'
            : '🍸';
  }
  content += "\n";

  BranchUniversalObject buo = BranchUniversalObject(
    canonicalIdentifier: 'flutter/branch',
    title: 'Happy Hour App',
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
    content += generatedLink;
    Share.share(content);
  } else {
    print('Error: ${response.errorMessage}');
  }
}
