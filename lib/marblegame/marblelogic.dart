/// Represents the game logic for a marble game.
///
/// The `GameLogic` class manages the game board, the current player, and the winning cells.
/// It provides methods to place a marble, switch the current player, and check for a win.
/// The game board is a 4x4 grid, and the game is played by two players, 'X' and 'O'.
/// The `shiftMarblesCounterclockwise()` method is used to shift the marbles on the board
/// in a counter-clockwise direction.
class GameLogic {
  static const int gridSize = 4;
  List<List<String?>> board;
  String currentPlayer;
  List<List<bool>> winningCells;

  GameLogic()
      : board = List.generate(gridSize, (_) => List.filled(gridSize, null)),
        currentPlayer = 'X',
        winningCells =
            List.generate(gridSize, (_) => List.filled(gridSize, false));

  bool placeMarble(int row, int col) {
    if (board[row][col] != null) return false;
    board[row][col] = currentPlayer;
    shiftMarblesCounterclockwise();
    return checkForWin();
  }

  void switchPlayer() {
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
  }

  bool checkForWin() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (_checkDirection(row, col, 1, 0) ||
            _checkDirection(row, col, 0, 1) ||
            _checkDirection(row, col, 1, 1) ||
            _checkDirection(row, col, 1, -1)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _checkDirection(int row, int col, int dRow, int dCol) {
    String? player = board[row][col];
    if (player == null) return false;

    List<List<int>> cells = [];
    for (int i = 0; i < 4; i++) {
      int newRow = row + dRow * i;
      int newCol = col + dCol * i;
      if (newRow < 0 ||
          newRow >= gridSize ||
          newCol < 0 ||
          newCol >= gridSize ||
          board[newRow][newCol] != player) {
        return false;
      }
      cells.add([newRow, newCol]);
    }

    for (var cell in cells) {
      winningCells[cell[0]][cell[1]] = true;
    }
    return true;
  }

  List<List<bool>> getWinningCells() {
    return winningCells;
  }

  void shiftMarblesCounterclockwise() {
    List<List<String?>> newBoard =
        List.generate(gridSize, (_) => List.filled(gridSize, null));

    List<List<int>> outerRing = [
      [0, 0],
      [0, 1],
      [0, 2],
      [0, 3],
      [1, 3],
      [2, 3],
      [3, 3],
      [3, 2],
      [3, 1],
      [3, 0],
      [2, 0],
      [1, 0]
    ];
    List<List<int>> innerRing = [
      [1, 1],
      [1, 2],
      [2, 2],
      [2, 1]
    ];

    for (int i = 0; i < outerRing.length; i++) {
      var next = outerRing[(i + 1) % outerRing.length];
      newBoard[next[0]][next[1]] = board[outerRing[i][0]][outerRing[i][1]];
    }

    for (int i = 0; i < innerRing.length; i++) {
      var next = innerRing[(i + 1) % innerRing.length];
      newBoard[next[0]][next[1]] = board[innerRing[i][0]][innerRing[i][1]];
    }

    board = newBoard;
  }
}
