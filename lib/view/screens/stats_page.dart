import 'package:drinks/data/widgets/circle_items.dart';
import 'package:drinks/data/widgets/info_container.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:drinks/view/screens/settings_page.dart';
import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
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
        title: const Text('All Time',
            style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ));
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.grey[800],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 30,
                    top: 30,
                    child: CircleItem(
                      color: Colors.white,
                      label: 'Beer',
                      percentage: '58%',
                      size: 180,
                      textColor: Colors.black,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    left: 160,
                    top: 40,
                    child: CircleItem(
                      color: Colors.grey[400]!,
                      label: 'Liquor',
                      percentage: '30%',
                      size: 140,
                      textColor: Colors.black,
                    ),
                  ),
                  Positioned(
                    right: 50,
                    left: 80,
                    top: 170,
                    child: CircleItem(
                      color: Colors.grey[600]!,
                      label: 'Wine',
                      percentage: '12%',
                      size: 80,
                      textColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                InfoContainer(label: 'TOTAL DRINKS', value: '75'),
                InfoContainer(label: 'LAST DRINK', value: '15 days ago'),
                InfoContainer(label: 'TOTAL BEERS', value: '61'),
                InfoContainer(label: 'LONGEST STREAK', value: '5 days'),
                InfoContainer(label: 'TOTAL LIQUOR', value: '35'),
                InfoContainer(label: 'LONGEST BREAK', value: '30 days'),
              ],
            ),
          ],
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
