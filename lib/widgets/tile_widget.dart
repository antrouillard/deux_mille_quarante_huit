import 'package:flutter/material.dart';

class TileWidget extends StatefulWidget {
  final int value;
  final bool merged;
  final bool isNew;
  final bool isExploding;

  const TileWidget({
    super.key,
    required this.value,
    this.merged = false,
    this.isNew = false,
    this.isExploding = false,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.isNew) {
      scale = 0.0;
      Future.delayed(Duration.zero, () {
        if (mounted) setState(() => scale = 1.0);
      });
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.merged) {
      setState(() => scale = 1.2);
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) setState(() => scale = 1.0);
      });
    } else if (widget.isExploding) {
      setState(() => scale = 1.3);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => scale = 0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _getTileColor(widget.value),
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.value == -1
            ? const Text(
                '💣',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : Text(
                '${widget.value}',
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
      case -1:
        return Colors.black;
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
