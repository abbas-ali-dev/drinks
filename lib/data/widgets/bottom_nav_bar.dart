import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:drinks/view/screens/monthly_page.dart';
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
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
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
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              shareContent();
            },
          ),
        ],
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
    content += "${DateFormat('EEE MM/dd/yy').format(today)}\n";

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
