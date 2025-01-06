import 'package:drinks/global/global_variable.dart';
import 'package:drinks/view/screens/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
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

    // Initialize hour controller based on time format
    _hourController = FixedExtentScrollController(
      initialItem: selectedTimeFormatGlobally == '24 Hour'
          ? _selectedTime.hour
          : _selectedTime.hour % 12,
    );

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
      content: SizedBox(
        height: 15.h,
        width: 10.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildHourScroller()),
            const Text(':  ',
                style: TextStyle(fontSize: 30, color: Colors.white)),
            Expanded(child: _buildMinuteScroller()),
            // Conditionally display AM/PM based on time format
            if (selectedTimeFormatGlobally == '12 Hour')
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      final newTime = _selectedTime.hour < 12
                          ? _selectedTime.add(const Duration(hours: 12))
                          : _selectedTime.subtract(const Duration(hours: 12));

                      setState(() {
                        _selectedTime = newTime;
                        _hourController.jumpToItem(_selectedTime.hour % 12);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _selectedTime.hour < 12 ? 'AM' : 'PM',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
            DateTime now = DateTime.now();

            // Create selected time
            DateTime selectedDateTime = DateTime(
              widget.initialTime.year,
              widget.initialTime.month,
              widget.initialTime.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );

            // Check if selected time is in the future
            if (selectedDateTime.isAfter(now)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('"You cannot select future time"'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            // If time is valid, update and close dialog
            widget.onTimeSelected(selectedDateTime);
            Navigator.pop(context);
          },
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildHourScroller() {
    return Padding(
      padding: EdgeInsets.only(
          right: selectedTimeFormatGlobally == '24 Hour' ? 20 : 50),
      child: SizedBox(
        width: selectedTimeFormatGlobally == '24 Hour' ? 80 : 60,
        height: 150,
        child: NumberPicker(
          value: selectedTimeFormatGlobally == '24 Hour'
              ? _selectedTime.hour
              : (_selectedTime.hour % 12 == 0 ? 12 : _selectedTime.hour % 12),
          minValue: selectedTimeFormatGlobally == '24 Hour' ? 0 : 1,
          maxValue: selectedTimeFormatGlobally == '24 Hour' ? 23 : 12,
          step: 1,
          infiniteLoop: true,
          textStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
          selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 23),
          onChanged: (value) {
            setState(() {
              int newHour = selectedTimeFormatGlobally == '24 Hour'
                  ? value
                  : (value == 12 ? 0 : value) +
                      (_selectedTime.hour >= 12 ? 12 : 0);
              _selectedTime = _selectedTime.copyWith(hour: newHour);
            });
          },
        ),
      ),
    );
  }

  Widget _buildMinuteScroller() {
    return SizedBox(
      width: 60,
      height: 150,
      child: NumberPicker(
        value: _selectedTime.minute,
        minValue: 0,
        maxValue: 59,
        step: 1,
        infiniteLoop: true,
        textStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
        selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 23),
        textMapper: (numberText) {
          return numberText == '0' ? '00' : numberText;
        },
        onChanged: (value) {
          setState(() {
            _selectedTime =
                _selectedTime.copyWith(minute: value == 60 ? 0 : value);
          });
        },
      ),
    );
  }
}
