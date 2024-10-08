import 'package:drinks/view/screens/home_page.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';

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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatsPage(),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
