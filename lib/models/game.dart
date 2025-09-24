import 'dart:math';

enum GameMode { classique, special, vitesse }

class Game {
  static const int size = 4;
  List<List<int>> board = List.generate(size, (_) => List.filled(size, 0));
  int score = 0;
  Set<Point<int>> mergedTiles = {};
  Set<Point<int>> newTiles = {};
  Set<Point<int>> explodingTiles = {};
  bool isGameOver = false;

  final GameMode mode;

  Game({this.mode = GameMode.classique}) {
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
      int rand = Random().nextInt(15);
      if (mode == GameMode.special && rand == 0) {
        board[pos.x][pos.y] = -1; // Special tile
      } else if (rand == 1) {
        board[pos.x][pos.y] = 4;
      } else {
        board[pos.x][pos.y] = 2;
      }
      newTiles.add(pos);
    }
  }

  bool moveWithoutNewTile(String direction) {
    mergedTiles.clear();
    newTiles.clear();

    List<List<int>> oldBoard = [
      for (var row in board) [...row]
    ];

    switch (direction) {
      case "left":
        for (var i = 0; i < size; i++) {
          board[i] = _merge(board[i], row: i, reverse: false);
        }
        break;
      case "right":
        for (var i = 0; i < size; i++) {
          board[i] = _merge(board[i].reversed.toList(), row: i, reverse: true)
              .reversed
              .toList();
        }
        break;
      case "up":
        for (var j = 0; j < size; j++) {
          List<int> col = [for (var i = 0; i < size; i++) board[i][j]];
          col = _merge(col, colIndex: j, reverse: false);
          for (var i = 0; i < size; i++) board[i][j] = col[i];
        }
        break;
      case "down":
        for (var j = 0; j < size; j++) {
          List<int> col = [for (var i = 0; i < size; i++) board[i][j]];
          col = _merge(col.reversed.toList(), colIndex: j, reverse: true)
              .reversed
              .toList();
          for (var i = 0; i < size; i++) board[i][j] = col[i];
        }
        break;
    }

    bool moved = !_areBoardsEqual(oldBoard, board);
    if (moved) {
      _checkGameOver();
    }
    return moved;
  }

  void addNewTileAfterMove() {
    _addNewTile();
    _checkGameOver();
  }

  List<int> _merge(List<int> line,
      {int? row, int? colIndex, bool reverse = false}) {
    line = line.where((v) => v != 0).toList();

    for (var i = 0; i < line.length - 1; i++) {
      int mergedIndex = -1;
      if (line[i] == -1 && line[i + 1] > 0) {
        mergedIndex = i;
      } else if (line[i + 1] == -1 && line[i] > 0) {
        mergedIndex = i + 1;
      }

      if (mergedIndex != -1) {
        explodingTiles.clear();
        int boardRow =
            row ?? (reverse ? (size - 1 - mergedIndex) : mergedIndex);
        int boardCol =
            colIndex ?? (reverse ? (size - 1 - mergedIndex) : mergedIndex);

        line[i] = 0;
        line[i + 1] = 0;

        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            int x = boardRow + dx;
            int y = boardCol + dy;
            if (x >= 0 && x < size && y >= 0 && y < size) {
              board[x][y] = 0;
              explodingTiles.add(Point(x, y));
            }
          }
        }
      }

      if (line[i] == line[i + 1]) {
        line[i] *= 2;
        score += line[i];
        line[i + 1] = 0;

        if (row != null) {
          int col = reverse ? (size - 1 - i) : i;
          mergedTiles.add(Point(row, col));
        } else if (colIndex != null) {
          int r = reverse ? (size - 1 - i) : i;
          mergedTiles.add(Point(r, colIndex));
        }
      }
    }

    line = line.where((v) => v != 0).toList();
    while (line.length < size) {
      line.add(0);
    }
    return line;
  }

  void _checkGameOver() {
    for (var row in board) {
      if (row.contains(0)) return;
    }
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        if (i < size - 1 && board[i][j] == board[i + 1][j]) return;
        if (j < size - 1 && board[i][j] == board[i][j + 1]) return;
      }
    }
    isGameOver = true;
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
