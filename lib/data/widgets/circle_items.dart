import 'package:flutter/material.dart';

class CircleItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;
  final double size;
  final Color textColor;

  CircleItem({
    required this.color,
    required this.label,
    required this.percentage,
    required this.size,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate a suitable font size based on the circle's size
    double fontSize = size * 0.1;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize, // Use calculated font size
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: fontSize * 1.2, // Slightly larger percentage
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
