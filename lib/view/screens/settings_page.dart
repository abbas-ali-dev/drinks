import 'package:drinks/global/global_variable.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:drinks/models/bottom_nav_bar.dart';
import 'package:sizer/sizer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _timeFormats = ['12 Hour', '24 Hour'];
  final List<String> _cutoffTimes = [
    '6:00 AM',
    '6:30 AM',
    '7:00 AM',
    '7:30 AM',
    '8:00 AM',
    '8:30 AM',
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            const Text(
              'Preferences',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Format',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                        width: 200,
                        child: Text(
                            'Toggle between 12 hour and 24 hour time format',
                            style: TextStyle(color: Colors.white))),
                  ],
                ),
                SizedBox(
                  width: 20.w,
                  child: DropdownButton<String>(
                    value: selectedTimeFormatGlobally,
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTimeFormatGlobally = newValue!;
                      });
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    items: _timeFormats.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cutoff Time',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                        width: 200,
                        child: Text(
                            'Choose the time when drinks are considered the following day',
                            style: TextStyle(color: Colors.white))),
                  ],
                ),
                SizedBox(
                  width: 20.w,
                  child: DropdownButton<String>(
                    value: selectedCutoffTimeGlobally,
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCutoffTimeGlobally = newValue!;
                      });
                      print(
                          'Selected cutoff time: $selectedCutoffTimeGlobally');
                    },
                    items: _cutoffTimes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

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
      bottomNavigationBar: const CustomBottumNavigationBar(),
    );
  }
}
