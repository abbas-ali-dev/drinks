import 'package:drinks/view/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class AnalogClockDialog extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime) onTimeSelected;

  const AnalogClockDialog({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  _AnalogClockDialogState createState() => _AnalogClockDialogState();
}

class _AnalogClockDialogState extends State<AnalogClockDialog> {
  late DateTime _selectedTime;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _hourController = FixedExtentScrollController(
        initialItem: _selectedTime.hour % 12); // Mod 12 for 12-hour format
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedTime.minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      title: const Text('Select Time',
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
      content: SizedBox(
        height: 20.h,
        width: 80.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHourScroller(),
            const Text(' : ',
                style: TextStyle(fontSize: 30, color: Colors.white)),
            _buildMinuteScroller(),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  _selectedTime.hour < 12 ? 'AM' : 'PM',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = _selectedTime.hour < 12
                          ? _selectedTime.add(const Duration(hours: 12))
                          : _selectedTime.subtract(const Duration(hours: 12));
                      _hourController.jumpToItem(_selectedTime.hour % 12);
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Toggle AM/PM',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            // Pass the updated _selectedTime to the callback
            widget.onTimeSelected(_selectedTime);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (route) => false,
            );
          },
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildHourScroller() {
    return SizedBox(
      width: 60,
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: _hourController,
        itemExtent: 40,
        perspective: 0.005,
        diameterRatio: 1,
        onSelectedItemChanged: (index) {
          setState(() {
            // Update the hour of the existing _selectedTime object
            _selectedTime = _selectedTime.copyWith(
              hour: (index + (_selectedTime.hour >= 12 ? 12 : 0)) % 24,
            );
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: 12,
          builder: (context, index) {
            int displayHour = (index) % 12;
            displayHour = displayHour == 0 ? 12 : displayHour;

            return Center(
              child: Text(
                '$displayHour',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMinuteScroller() {
    return SizedBox(
      width: 60,
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: _minuteController,
        itemExtent: 40,
        perspective: 0.005,
        diameterRatio: 1,
        onSelectedItemChanged: (index) {
          setState(() {
            // Update the minute of the existing _selectedTime object
            _selectedTime = _selectedTime.copyWith(minute: index);
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: 60,
          builder: (context, index) {
            return Center(
              child: Text(
                '$index'.padLeft(2, '0'),
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
