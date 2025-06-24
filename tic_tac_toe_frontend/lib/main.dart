import 'package:flutter/material.dart';

// Tic Tac Toe colors as per theme
const Color kPrimaryColor = Color(0xFF2196F3);
const Color kSecondaryColor = Color(0xFFFFC107);
const Color kAccentColor = Color(0xFF4CAF50);

// Entry point of the app
void main() {
  runApp(TicTacToeApp());
}

// PUBLIC_INTERFACE
class TicTacToeApp extends StatelessWidget {
  /// Root widget of the tic tac toe app with theme applied.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
        ),
        primaryColor: kPrimaryColor,
        useMaterial3: true,
      ),
      home: const TicTacToeHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// PUBLIC_INTERFACE
class TicTacToeHome extends StatefulWidget {
  /// Main game page.
  const TicTacToeHome({Key? key}) : super(key: key);

  @override
  State<TicTacToeHome> createState() => _TicTacToeHomeState();
}

class _TicTacToeHomeState extends State<TicTacToeHome> {
  static const int boardSize = 3;
  late List<List<String?>> _board;
  String _currentPlayer = 'X';
  String? _winner;
  bool _draw = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  // PUBLIC_INTERFACE
  void _resetGame() {
    /// Resets the game to the initial state.
    setState(() {
      _board = List.generate(boardSize, (_) => List.filled(boardSize, null));
      _currentPlayer = 'X';
      _winner = null;
      _draw = false;
    });
  }

  // PUBLIC_INTERFACE
  void _handleTap(int row, int col) {
    /// Handles user input for marking the board.
    if (_board[row][col] != null || _winner != null) {
      // Already occupied or game ended
      return;
    }
    setState(() {
      _board[row][col] = _currentPlayer;
      _winner = _checkWinner();
      if (_winner == null && _isBoardFull()) {
        _draw = true;
      } else if (_winner == null) {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  // PUBLIC_INTERFACE
  String? _checkWinner() {
    /// Returns the winner ('X' or 'O') if there is one, or null if not yet.
    // Rows and columns
    for (int i = 0; i < boardSize; i++) {
      if (_board[i][0] != null &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2]) {
        return _board[i][0];
      }
      if (_board[0][i] != null &&
          _board[0][i] == _board[1][i] &&
          _board[1][i] == _board[2][i]) {
        return _board[0][i];
      }
    }
    // Diagonals
    if (_board[0][0] != null &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2]) {
      return _board[0][0];
    }
    if (_board[0][2] != null &&
        _board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0]) {
      return _board[0][2];
    }
    return null;
  }

  // PUBLIC_INTERFACE
  bool _isBoardFull() {
    /// Returns true if the board is full, false otherwise.
    for (var row in _board) {
      for (var cell in row) {
        if (cell == null) return false;
      }
    }
    return true;
  }

  // PUBLIC_INTERFACE
  String _getStatusText() {
    /// Returns the status message to be displayed.
    if (_winner != null) {
      return 'Player $_winner wins!';
    } else if (_draw) {
      return "It's a draw!";
    } else {
      return "Player $_currentPlayer's turn";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: board is always centered and square
            double boardSizePx = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth * 0.85
                : constraints.maxHeight * 0.45;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status display above
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Board UI centered
                Container(
                  width: boardSizePx,
                  height: boardSizePx,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 16,
                        offset: Offset(4, 8),
                      )
                    ],
                  ),
                  child: _buildBoard(boardSizePx / boardSize),
                ),
                // Controls below
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: Icon(Icons.refresh, color: kPrimaryColor),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: kPrimaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 26),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    label: const Text("Reset Game"),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoard(double cellSize) {
    // Board widget with all marks and logic.
    List<TableRow> rows = [];
    for (int row = 0; row < boardSize; row++) {
      List<Widget> cells = [];
      for (int col = 0; col < boardSize; col++) {
        cells.add(_buildCell(row, col, cellSize));
      }
      rows.add(TableRow(children: cells));
    }
    return Table(children: rows);
  }

  Widget _buildCell(int row, int col, double cellSize) {
    // Board cell widget (tapable)
    final cell = _board[row][col];
    return GestureDetector(
      onTap: () {
        _handleTap(row, col);
      },
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
                width: row == 0 ? 0 : 2, color: Colors.grey.shade300),
            left: BorderSide(
                width: col == 0 ? 0 : 2, color: Colors.grey.shade300),
            right: BorderSide(
                width: col == boardSize - 1 ? 0 : 2,
                color: Colors.grey.shade300),
            bottom: BorderSide(
                width: row == boardSize - 1 ? 0 : 2,
                color: Colors.grey.shade300),
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: cell == null
                ? null
                : Text(
                    cell,
                    key: ValueKey('$row$col$cell'),
                    style: TextStyle(
                      fontSize: cellSize * 0.55,
                      fontWeight: FontWeight.bold,
                      color:
                          cell == 'X' ? kPrimaryColor : kSecondaryColor,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.grey.shade300,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
