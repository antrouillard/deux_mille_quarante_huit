import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  final List<List<int>> board;
  final Set<Point<int>> mergedTiles;
  final Set<Point<int>> newTiles;
  final Set<Point<int>> explodingTiles;

  const BoardWidget({
    super.key,
    required this.board,
    required this.mergedTiles,
    required this.newTiles,
    required this.explodingTiles,
  });

  @override
  Widget build(BuildContext context) {
    final double totalSize = MediaQuery.of(context).size.width * 0.9;
    final double tileSize = totalSize / Game.size;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Game.size,
            ),
            itemCount: Game.size * Game.size,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
          ...List.generate(Game.size, (i) {
            return List.generate(Game.size, (j) {
              final int value = board[i][j];
              if (value == 0) return const SizedBox();

              final pos = Point(i, j);
              final merged = mergedTiles.contains(pos);
              final isNew = newTiles.contains(pos);
              final isExploding = explodingTiles.contains(pos);

              return AnimatedPositioned(
                key: ValueKey('tile_${i}_$j\_$value'),
                duration: const Duration(milliseconds: 150),
                left: j * tileSize,
                top: i * tileSize,
                child: SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: TileWidget(
                      value: value,
                      merged: merged,
                      isNew: isNew,
                      isExploding: isExploding),
                ),
              );
            });
          }).expand((e) => e),
        ],
      ),
    );
  }
}
