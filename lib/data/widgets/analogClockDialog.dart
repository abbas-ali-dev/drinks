import 'package:drinks/global/global_variable.dart';
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
                      setState(() {
                        _selectedTime = _selectedTime.hour < 12
                            ? _selectedTime.add(const Duration(hours: 12))
                            : _selectedTime.subtract(const Duration(hours: 12));
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
            // Check if the selected time is in the future
            if (_selectedTime.isAfter(DateTime.now())) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You can't select a future time."),
                ),
              );
              return; // Don't close the dialog
            }

            // Pass the updated _selectedTime to the callback
            widget.onTimeSelected(_selectedTime);
            Navigator.pop(context);
          },
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Widget _buildHourScroller() {
  //   return Padding(
  //     padding: EdgeInsets.only(
  //         right: selectedTimeFormatGlobally == '24 Hour' ? 10 : 50),
  //     child: SizedBox(
  //       width: selectedTimeFormatGlobally == '24 Hour' ? 80 : 60,
  //       height: 150,
  //       child: ListWheelScrollView.useDelegate(
  //         controller: _hourController,
  //         itemExtent: 40,
  //         perspective: 0.005,
  //         diameterRatio: 1.0,
  //         physics: const FixedExtentScrollPhysics(
  //             parent: BouncingScrollPhysics(
  //                 decelerationRate: ScrollDecelerationRate.fast)),
  //         onSelectedItemChanged: (index) {
  //           setState(() {
  //             int newHour = selectedTimeFormatGlobally == '24 Hour'
  //                 ? index
  //                 : (index + (_selectedTime.hour >= 12 ? 12 : 0)) % 24;

  //             // Prevent selecting future hours
  //             if (newHour > DateTime.now().hour &&
  //                 _selectedTime.day == DateTime.now().day) {
  //               newHour = DateTime.now().hour;
  //             }

  //             _selectedTime = _selectedTime.copyWith(hour: newHour);

  //             // Adjust scrolling for 24-hour format
  //             _hourController.animateToItem(
  //               selectedTimeFormatGlobally == '24 Hour'
  //                   ? newHour
  //                   : newHour % 12,
  //               duration: const Duration(milliseconds: 300),
  //               curve: Curves.easeInOut,
  //             );
  //           });
  //         },
  //         childDelegate: ListWheelChildBuilderDelegate(
  //           childCount: selectedTimeFormatGlobally == '24 Hour' ? 24 : 12,
  //           builder: (context, index) {
  //             int displayHour = selectedTimeFormatGlobally == '24 Hour'
  //                 ? index
  //                 : (index) % 12;
  //             displayHour = displayHour == 0 ? 12 : displayHour;

  //             return Center(
  //               child: Text(
  //                 '$displayHour',
  //                 style: const TextStyle(fontSize: 23, color: Colors.white),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMinuteScroller() {
  //   return SizedBox(
  //     width: 60,
  //     height: 150,
  //     child: ListWheelScrollView.useDelegate(
  //       controller: _minuteController,
  //       itemExtent: 40,
  //       perspective: 0.005,
  //       diameterRatio: 1,
  //       physics: const FixedExtentScrollPhysics(
  //         parent: BouncingScrollPhysics(
  //             decelerationRate: ScrollDecelerationRate.fast),
  //       ),
  //       onSelectedItemChanged: (index) {
  //         setState(() {
  //           int newMinute = index;
  //           _selectedTime = _selectedTime.copyWith(minute: newMinute);
  //           _minuteController.animateToItem(
  //             newMinute,
  //             duration: const Duration(milliseconds: 100),
  //             curve: Curves.easeOut,
  //           );
  //         });
  //       },
  //       childDelegate: ListWheelChildBuilderDelegate(
  //         childCount: 60,
  //         builder: (context, index) {
  //           return Center(
  //             child: Text(
  //               '$index'.padLeft(2, '0'),
  //               style: const TextStyle(fontSize: 23, color: Colors.white),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
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
              if (newHour > DateTime.now().hour &&
                  _selectedTime.day == DateTime.now().day) {
                newHour = DateTime.now().hour;
              }
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
        value: _selectedTime.minute == 0 ? 00 : _selectedTime.minute,
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
