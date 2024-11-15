/// The `MarbleGameScreen` is the main screen for the two-player marble game.
/// It handles the game logic, user interactions, and the visual representation of the game.
///
/// The screen displays a grid of cells where players can place their marbles.
/// The game is won when a player forms a continuous line of their marbles.
/// The screen also includes a timer that limits the time for each player's turn.
///
/// The screen provides the following functionality:
/// - Initializes the game logic and the game state
/// - Handles user taps on the game board to place marbles
/// - Manages the turn timer and switches players when the timer expires
/// - Detects and displays the winner when a player forms a winning line
/// - Provides a "Restart Game" button to reset the game
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marblegame/marblegame/marblelogic.dart';

class MarbleGameScreen extends StatefulWidget {
  const MarbleGameScreen({super.key});

  @override
  _MarbleGameScreenState createState() => _MarbleGameScreenState();
}

class _MarbleGameScreenState extends State<MarbleGameScreen> {
  late GameLogic gameLogic;
  bool gameWon = false;
  List<List<bool>> highlightCells = [];
  Timer? turnTimer;
  int remainingTime = 10; // 10 seconds per turn

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic();
    highlightCells = List.generate(
        GameLogic.gridSize, (_) => List.filled(GameLogic.gridSize, false));
    startTurnTimer();
  }

  void startTurnTimer() {
    turnTimer?.cancel(); // Cancel any existing timer
    remainingTime = 10; // Reset timer for the new turn
    turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime--;
        if (remainingTime <= 0) {
          timer.cancel();
          handleTurnTimeout();
        }
      });
    });
  }

  void handleTurnTimeout() {
    // Switch player if turn times out
    if (!gameWon) {
      gameLogic.switchPlayer();
      startTurnTimer();
    }
  }

  void handleCellTap(int row, int col) {
    if (gameWon || gameLogic.board[row][col] != null) return;

    bool win = gameLogic.placeMarble(row, col);
    if (win) {
      setState(() {
        gameWon = true;
        highlightCells = gameLogic.getWinningCells();
      });
      turnTimer?.cancel(); // Stop the timer if game ends
    } else {
      gameLogic.switchPlayer();
      startTurnTimer();
    }
    setState(() {});
  }

  void restartGame() {
    setState(() {
      gameLogic = GameLogic();
      gameWon = false;
      highlightCells = List.generate(
          GameLogic.gridSize, (_) => List.filled(GameLogic.gridSize, false));
    });
    startTurnTimer();
  }

  @override
  void dispose() {
    turnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Two-Player Marble Game"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    gameWon
                        ? "Player ${gameLogic.currentPlayer} Wins!"
                        : "Player ${gameLogic.currentPlayer}'s Turn",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Time Left: $remainingTime seconds",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            for (int row = 0; row < GameLogic.gridSize; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int col = 0; col < GameLogic.gridSize; col++)
                    GestureDetector(
                      onTap: () => handleCellTap(row, col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: highlightCells[row][col]
                              ? Colors.amber
                              : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            gameLogic.board[row][col] ?? '',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: restartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Restart Game",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
