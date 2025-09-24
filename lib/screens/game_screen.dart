import 'package:flutter/material.dart';
import '../models/game.dart';
import '../widgets/board_widget.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game game;
  Timer? _moveTimer;
  static const int moveTimeoutSeconds = 5;
  double _timerProgress = 1.0;
  DateTime? _timerStart;
  int _moveCount = 0;
  double _currentTimeout = moveTimeoutSeconds.toDouble();

  @override
  void initState() {
    super.initState();
    game = Game();
    _startMoveTimer();
  }

  void _startMoveTimer() {
    _moveTimer?.cancel();
    _timerStart = DateTime.now();
    _timerProgress = 1.0;
    setState(() {});

    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final elapsed = DateTime.now().difference(_timerStart!).inMilliseconds;
      final total = (_currentTimeout * 1000).toInt();
      setState(() {
        _timerProgress = 1.0 - (elapsed / total);
        if (_timerProgress <= 0) {
          _timerProgress = 0;
          timer.cancel();
          _playRandomMove();
        }
      });
    });
  }

  void _playRandomMove() {
    final directions = ['left', 'right', 'up', 'down'];
    final random = Random();
    final dir = directions[random.nextInt(directions.length)];
    _onSwipe(dir);
  }

  void _onSwipe(String direction) async {
    _moveTimer?.cancel();
    _timerProgress = 1.0;
    bool moved = game.moveWithoutNewTile(direction);
    if (moved) {
      _moveCount++;
      // Decrease timer every 10 moves, but not below 1 second
      if (_moveCount % 10 == 0 && _currentTimeout > 1.0) {
        setState(() {
          _currentTimeout =
              (_currentTimeout - 0.5).clamp(1.0, moveTimeoutSeconds.toDouble());
        });
      }

      setState(() {});

      // Step 2: After a short delay, add new tile and animate its appearance
      await Future.delayed(const Duration(milliseconds: 10));
      setState(() {
        game.addNewTileAfterMove();
        if (game.isGameOver) {
          _showGameOverDialog();
        }
      });
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        game.explodingTiles.clear();
        game.mergedTiles.clear();
      });
    }
    _startMoveTimer();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score final : ${game.score}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => game = Game());
            },
            child: const Text("Rejouer"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _onSwipe("up");
        } else {
          _onSwipe("down");
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _onSwipe("left");
        } else {
          _onSwipe("right");
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("2048 Flutter")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SCORE
              Text("Score: ${game.score}",
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              // MOVE TIMER
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: 200 * (_currentTimeout / moveTimeoutSeconds),
                child: LinearProgressIndicator(
                  value: _timerProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              BoardWidget(
                board: game.board,
                mergedTiles: game.mergedTiles,
                newTiles: game.newTiles,
                explodingTiles: game.explodingTiles,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    game = Game();
                    _moveCount = 0;
                    _currentTimeout = moveTimeoutSeconds.toDouble();
                    _moveTimer?.cancel();
                    _startMoveTimer();
                  });
                },
                child: const Text("Nouvelle Partie"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
