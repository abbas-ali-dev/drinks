import 'package:drinks/global/global_variable.dart';
import 'package:drinks/models/drink_model.dart';
import 'package:drinks/view/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:drinks/data/widgets/bottom_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      debugPrint(
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
            GestureDetector(
              onTap: () {
                _launchEmail();
              },
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please send any feedback to halfpriceappz@gmail.com',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _showClearDataConfirmationDialog(context);
              },
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clear All Data',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Clear all stored drinks',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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

  Future<void> _launchEmail() async {
    final Uri gmailInboxUri = Uri.parse(
        'https://mail.google.com/mail/u/0/?tab=rm&ogbl#inbox?Subject=Feedback');
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'halfpriceappz@gmail.com',
      queryParameters: {
        'subject': 'Feedback_for_Drink_App',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      return;
    }

    if (await canLaunchUrl(gmailInboxUri)) {
      await launchUrl(emailLaunchUri);
      return;
    }

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback'),
        content: const Text(
            'Could not open Gmail or your mail app. Please send your feedback to:\nhalfpriceappz@gmail.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDataConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Clear All Data?',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to clear all data?\n',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Clear Data',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                // Clear Hive box
                Hive.box<Drink>('drinksBox').clear();

                // Show a snackbar to confirm data clearance
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All the data has been cleared.',
                        style: TextStyle(color: Colors.white)),
                  ),
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
