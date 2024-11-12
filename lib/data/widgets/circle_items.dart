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

    // Set a minimum size for the circle
    double finalSize = size < 50 ? 50 : size; // Minimum size of 50

    return SizedBox(
      width: finalSize,
      height: finalSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: finalSize,
            height: finalSize,
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
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
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
