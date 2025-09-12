import 'package:flutter/material.dart';
import '../models/game.dart';
import '../widgets/board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game game;

  @override
  void initState() {
    super.initState();
    game = Game();
  }

  void _onSwipe(String direction) {
    setState(() {
      game.move(direction);
    });
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Score: ${game.score}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            BoardWidget(board: game.board),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  game = Game();
                });
              },
              child: const Text("Nouvelle Partie"),
            ),
          ],
        ),
      ),
    );
  }
}
