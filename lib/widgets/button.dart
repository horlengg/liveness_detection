import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color labelColor;
  final Color backgroundColor;
  final double radius;
  final Size? minimumSize;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.labelColor = Colors.white,
    this.backgroundColor = const Color(0xFF035F9E),
    this.radius = 12.0,
    this.minimumSize = const Size(200, 50)
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: minimumSize,
          backgroundColor: backgroundColor,
          foregroundColor: labelColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Text(label,style: TextStyle(fontSize: 12)),
      ),
    );
  }
}
