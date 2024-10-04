import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   color: Colors.white,
        //   icon: const Icon(
        //     Icons.arrow_back,
        //   ),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Section
            const Text(
              'Preferences',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildPreferenceRow('Time Format',
                'Toggle between 12 hour and 24 hour time format', '12 Hour'),
            const SizedBox(height: 20),
            _buildPreferenceRow(
                'Cutoff Time',
                'Choose the time when drinks are considered the following day',
                '6:00 AM'),

            const SizedBox(height: 40),
            const Text(
              'Other',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Feedback',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please send any feedback to halfpriceappz@gmail.com',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Clear All Data',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Clear all stored drinks (cannot be undone)',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Version Section
            const Text(
              'Version',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('1.0.0', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart_sharp, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceRow(String title, String subtitle, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            SizedBox(
                width: 200,
                child: Text(subtitle,
                    style: const TextStyle(color: Colors.white))),
          ],
        ),
        Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Container(
              height: 1,
              width: 80,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}
