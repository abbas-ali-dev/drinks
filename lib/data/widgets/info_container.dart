import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class InfoContainer extends StatelessWidget {
  final String label;
  final String value;

  InfoContainer({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      width: 39.w,
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
