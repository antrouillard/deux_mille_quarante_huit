import 'package:flutter/material.dart';
import '../models/game.dart';
import '../widgets/board_widget.dart';
import 'dart:async';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game game;
  GameMode _selectedMode = GameMode.classique;
  // TIMER
  Timer? _moveTimer;
  static const int moveTimeoutSeconds = 5;
  double _timerProgress = 1.0;
  DateTime? _timerStart;
  int _moveCount = 0;
  double _currentTimeout = moveTimeoutSeconds.toDouble();

  @override
  void initState() {
    super.initState();
    game = Game(mode: _selectedMode);
    if (_selectedMode == GameMode.vitesse) {
      _startMoveTimer();
    }
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
    if (_selectedMode == GameMode.vitesse) {
      _moveTimer?.cancel();
      _timerProgress = 1.0;
    }

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
    if (_selectedMode == GameMode.vitesse) {
      _startMoveTimer();
    }
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
              setState(() {
                game.updateBestScore();
                game = Game(mode: _selectedMode);
                _moveCount = 0;
                _currentTimeout = moveTimeoutSeconds.toDouble();
                _moveTimer?.cancel();
                _startMoveTimer();
              });
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'static/icon/image.png',
                    height: 215, // Adjust as needed
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // MODE DROPDOWN
              LayoutBuilder(
                builder: (context, constraints) {
                  // Choose a width that is a fraction of the screen, or at least a minimum
                  double dropdownWidth =
                      constraints.maxWidth * 0.6; // 60% of screen width
                  dropdownWidth = dropdownWidth < 220
                      ? 220
                      : dropdownWidth; // Minimum width

                  return SizedBox(
                    width: dropdownWidth,
                    child: DropdownButton2<GameMode>(
                      isExpanded: true,
                      value: _selectedMode,
                      underline: const SizedBox.shrink(),
                      onChanged: (mode) {
                        if (mode != null) {
                          setState(() {
                            _selectedMode = mode;
                            game = Game(mode: _selectedMode);
                            _moveCount = 0;
                            _currentTimeout = moveTimeoutSeconds.toDouble();
                            _moveTimer?.cancel();
                            if (_selectedMode == GameMode.vitesse) {
                              _startMoveTimer();
                            }
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: GameMode.classique,
                          child: Center(
                              child: Text("Classique",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 25))),
                        ),
                        DropdownMenuItem(
                          value: GameMode.special,
                          child: Center(
                              child: Text("Spécial",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 252, 217, 61),
                                      fontSize: 30,
                                      fontFamily: 'Bellyn'))),
                        ),
                        DropdownMenuItem(
                          value: GameMode.vitesse,
                          child: Center(
                              child: Text("Vitesse",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 24, 167, 203),
                                      fontSize: 25,
                                      fontFamily: 'Elektrik'))),
                        ),
                      ],
                      buttonStyleData: ButtonStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[100],
                          border: Border.all(
                              color: Colors.blueGrey.shade200, width: 2),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(Icons.arrow_drop_down,
                            color: Colors.orange, size: 28),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // SCORE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Score: ${game.score}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (game.bestScore > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      "(${game.bestScore})",
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black38,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              // MOVE TIMER
              if (_selectedMode == GameMode.vitesse)
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

              const SizedBox(height: 10),
              // BOARD
              BoardWidget(
                board: game.board,
                mergedTiles: game.mergedTiles,
                newTiles: game.newTiles,
                explodingTiles: game.explodingTiles,
              ),
              const SizedBox(height: 20),
              // NEW GAME BUTTON
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    game.updateBestScore();
                    game = Game(mode: _selectedMode);
                    _moveCount = 0;
                    _currentTimeout = moveTimeoutSeconds.toDouble();
                    _moveTimer?.cancel();
                    if (_selectedMode == GameMode.vitesse) {
                      _startMoveTimer();
                    }
                  });
                },
                child: const Text("Nouvelle partie",
                    style: TextStyle(fontSize: 25)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
