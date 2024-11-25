import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class InfoContainer extends StatelessWidget {
  final String label;
  final String value;

  InfoContainer({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 7.h,
        width: 40.w,
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
