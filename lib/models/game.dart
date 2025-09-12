import 'dart:math';

class Game {
  static const int size = 4;
  List<List<int>> board = List.generate(size, (_) => List.filled(size, 0));
  int score = 0;

  Game() {
    _addNewTile();
    _addNewTile();
  }

  void _addNewTile() {
    final empty = <Point<int>>[];
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        if (board[i][j] == 0) empty.add(Point(i, j));
      }
    }
    if (empty.isNotEmpty) {
      final pos = empty[Random().nextInt(empty.length)];
      board[pos.x][pos.y] = Random().nextInt(10) == 0 ? 4 : 2;
    }
  }

  // TODO: implémenter les mouvements (left, right, up, down)
  // Chaque mouvement doit fusionner les tuiles et mettre à jour le score.
}
