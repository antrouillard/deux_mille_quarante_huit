import 'package:flutter/material.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  final List<List<int>> board;

  const BoardWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          final x = index ~/ 4;
          final y = index % 4;
          return TileWidget(value: board[x][y]);
        },
      ),
    );
  }
}
