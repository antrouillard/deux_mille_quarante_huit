import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int value;

  const TileWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value == 0 ? '' : '$value',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      default:
        return Colors.black54;
    }
  }
}
