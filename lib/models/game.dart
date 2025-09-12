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

  bool move(String direction) {
    List<List<int>> oldBoard = [
      for (var row in board) [...row]
    ];

    switch (direction) {
      case "left":
        for (var i = 0; i < size; i++) {
          board[i] = _merge(board[i]);
        }
        break;

      case "right":
        for (var i = 0; i < size; i++) {
          board[i] = _merge(board[i].reversed.toList()).reversed.toList();
        }
        break;

      case "up":
        for (var j = 0; j < size; j++) {
          List<int> col = [for (var i = 0; i < size; i++) board[i][j]];
          col = _merge(col);
          for (var i = 0; i < size; i++) board[i][j] = col[i];
        }
        break;

      case "down":
        for (var j = 0; j < size; j++) {
          List<int> col = [for (var i = 0; i < size; i++) board[i][j]];
          col = _merge(col.reversed.toList()).reversed.toList();
          for (var i = 0; i < size; i++) board[i][j] = col[i];
        }
        break;
    }

    // Vérifie si la grille a changé
    bool moved = !_areBoardsEqual(oldBoard, board);
    if (moved) _addNewTile();
    return moved;
  }

  List<int> _merge(List<int> line) {
    // Compresse : enlève les zéros
    line = line.where((v) => v != 0).toList();

    for (var i = 0; i < line.length - 1; i++) {
      if (line[i] == line[i + 1]) {
        line[i] *= 2;
        score += line[i]; // ✅ ajout du score (fusion)
        line[i + 1] = 0;
      }
    }

    // Retire les 0 créés par fusion et complète à droite avec des zéros
    line = line.where((v) => v != 0).toList();
    while (line.length < size) {
      line.add(0);
    }

    return line;
  }

  bool _areBoardsEqual(List<List<int>> b1, List<List<int>> b2) {
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        if (b1[i][j] != b2[i][j]) return false;
      }
    }
    return true;
  }
}
