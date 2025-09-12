import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int value;

  const TileWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: value == 0 ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: Text(
          value == 0 ? '' : '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int val) {
    switch (val) {
      case 2:
        return Colors.grey[300]!;
      case 4:
        return Colors.grey[400]!;
      case 8:
        return Colors.orange;
      case 16:
        return Colors.deepOrange;
      case 32:
        return Colors.red;
      case 64:
        return Colors.redAccent;
      case 128:
        return Colors.yellow[700]!;
      case 256:
        return Colors.yellow[800]!;
      case 512:
        return Colors.green;
      case 1024:
        return Colors.teal;
      case 2048:
        return Colors.purple;
      default:
        return Colors.black54;
    }
  }
}
