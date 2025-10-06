import 'package:flutter/material.dart';
import '../models/game.dart';
import '../widgets/board_widget.dart';
import 'dart:async';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadBestScore();
    if (_selectedMode == GameMode.vitesse) {
      _startMoveTimer();
    }
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final bestScore = prefs.getInt('best_score_${_selectedMode.name}') ?? 0;
    setState(() {
      game.bestScore = bestScore;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score_${_selectedMode.name}', game.bestScore);
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
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score final : ${game.score}"),
        actions: [
          TextButton(
            onPressed: () async {
              game.updateBestScore();
              await _saveBestScore(); // Save the best score
              Navigator.pop(context);
              setState(() {
                game = Game(mode: _selectedMode);
                _moveCount = 0;
                _currentTimeout = moveTimeoutSeconds.toDouble();
                _moveTimer?.cancel();
              });
              await _loadBestScore();
              if (_selectedMode == GameMode.vitesse) {
                _startMoveTimer();
              }
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F5DC), // Beige
                Color(0xFFE8DCC4), // Light tan
                Color(0xFFD4C4A8), // Warm beige
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive sizes
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;
              double logoHeight = (screenHeight * 0.2).clamp(80.0, 440.0);
              double dropdownWidth = (screenWidth * 0.4).clamp(110.0, 400.0);

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LOGO
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Shadow layer
                          Positioned(
                            left: 2,
                            top: 2,
                            child: Opacity(
                              opacity: 0.3,
                              child: Image.asset(
                                'static/icon/image.png',
                                height: logoHeight,
                                fit: BoxFit.contain,
                                color: Colors.black,
                                colorBlendMode: BlendMode.srcATop,
                              ),
                            ),
                          ),
                          // Actual image
                          Image.asset(
                            'static/icon/image.png',
                            height: logoHeight,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    // MODE DROPDOWN
                    SizedBox(
                      width: dropdownWidth,
                      child: DropdownButton2<GameMode>(
                        isExpanded: true,
                        value: _selectedMode,
                        underline: const SizedBox.shrink(),
                        onChanged: (mode) async {
                          if (mode != null) {
                            setState(() {
                              _selectedMode = mode;
                              game = Game(mode: _selectedMode);
                              _moveCount = 0;
                              _currentTimeout = moveTimeoutSeconds.toDouble();
                              _moveTimer?.cancel();
                            });
                            await _loadBestScore();
                            if (_selectedMode == GameMode.vitesse) {
                              _startMoveTimer();
                            }
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: GameMode.classique,
                            child: Center(
                              child: Text(
                                "Classique",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: GameMode.special,
                            child: Center(
                              child: Text(
                                "Spécial",
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 252, 217, 61),
                                  fontSize: screenWidth * 0.045,
                                  fontFamily: 'Bellyn',
                                ),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: GameMode.vitesse,
                            child: Center(
                              child: Text(
                                "Vitesse",
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 24, 167, 203),
                                  fontSize: screenWidth * 0.045,
                                  fontFamily: 'Elektrik',
                                ),
                              ),
                            ),
                          ),
                        ],
                        buttonStyleData: ButtonStyleData(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenHeight * 0.015),
                            color: Colors.grey[100],
                            border: Border.all(
                              color: Colors.blueGrey.shade200,
                              width: screenWidth * 0.004,
                            ),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenHeight * 0.015),
                            color: Colors.white,
                          ),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.orange,
                            size: screenHeight * 0.03,
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: screenHeight * 0.045,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.012),
                        ),
                      ),
                    ),
                    // SCORE
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Score: ${game.score}",
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (game.bestScore > 0) ...[
                            SizedBox(width: screenWidth * 0.015),
                            Text(
                              "(${game.bestScore})",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // MOVE TIMER
                    if (_selectedMode == GameMode.vitesse)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: (screenWidth * 0.5) *
                            (_currentTimeout / moveTimeoutSeconds),
                        child: LinearProgressIndicator(
                          value: _timerProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                          minHeight: screenHeight * 0.008,
                        ),
                      ),
                    // BOARD
                    Flexible(
                      child: BoardWidget(
                        board: game.board,
                        mergedTiles: game.mergedTiles,
                        newTiles: game.newTiles,
                        explodingTiles: game.explodingTiles,
                      ),
                    ),
                    // NEW GAME BUTTON
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEDC967),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.012,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () async {
                          game.updateBestScore();
                          await _saveBestScore();
                          setState(() {
                            game = Game(mode: _selectedMode);
                            _moveCount = 0;
                            _currentTimeout = moveTimeoutSeconds.toDouble();
                            _moveTimer?.cancel();
                          });
                          await _loadBestScore();
                          if (_selectedMode == GameMode.vitesse) {
                            _startMoveTimer();
                          }
                        },
                        child: Text(
                          "Nouvelle partie",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
