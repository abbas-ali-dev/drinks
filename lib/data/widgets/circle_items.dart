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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 20,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
