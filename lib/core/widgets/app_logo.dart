import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final BorderRadiusGeometry borderRadius;

  const AppLogo({
    super.key,
    this.size = 72,
    this.iconSize = 40,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(76, 46, 125, 50),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
