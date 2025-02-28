import 'dart:math'; // Importing the math library for random number generation
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(title: 'Noughts and Crosses'), // Main game page
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // State variables
  List<String> grid = List.generate(9, (_) => ''); // 3x3 grid for the game
  bool isX = true; // Track whose turn it is; true for 'X', false for 'O'
  String winner = ''; // Track the winner of the game
  List<int> winningLine = []; // Store the winning line indexes
  String gameMode = 'Human vs Human'; // Default game mode
  String difficultyLevel = 'Easy'; // Default difficulty for AI

  final Random _random = Random(); // Random generator for Easy AI
  List<List<String>> moveHistory = []; // Stack to keep track of moves for undo functionality

  // Scoring variables
  int xScore = 0; // Score for player X
  int oScore = 0; // Score for player O

  // Function to handle tapping on a grid cell
  void _onTap(int index) {
    if (grid[index] == '' && winner == '') { // Check if the cell is empty and game is still ongoing
      _saveState(); // Save current state before making a move
      setState(() {
        grid[index] = isX ? 'X' : 'O'; // Set the grid cell to 'X' or 'O'
        isX = !isX; // Switch player
        winner = _checkWinner(); // Check if there's a winner
        print('Grid: $grid, Winner: $winner'); // Debugging statement

        // If it's the computer's turn in human vs computer mode
        if (gameMode == 'Human vs Computer' && winner == '' && !isX) {
          _computerMove(); // Make the computer's move
        }
      });
    }
  }

  // Function for computer's move based on the selected difficulty
  void _computerMove() {
    if (difficultyLevel == 'Easy') {
      _easyMove(); // Make an easy AI move
    } else if (difficultyLevel == 'Hard') {
      _hardMove(); // Make a hard AI move using minimax
    }
  }

  // Easy mode: Randomly pick an empty spot
  void _easyMove() {
    List<int> availableSpots = []; // List to track available spots
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == '') availableSpots.add(i); // Add empty spots to the list
    }
    if (availableSpots.isNotEmpty) {
      int randomIndex = _random.nextInt(availableSpots.length); // Pick a random index
      _saveState(); // Save current state before making a move
      setState(() {
        grid[availableSpots[randomIndex]] = 'O'; // Make the computer move
        isX = true; // Switch back to player 'X'
        winner = _checkWinner(); // Check for a winner
      });
    }
  }

  // Hard mode: Minimax algorithm to determine the best move
  void _hardMove() {
    int bestScore = -1000; // Initialize best score
    int bestMove = -1; // Initialize best move index

    // Evaluate all possible moves
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == '') { // If the cell is empty
        grid[i] = 'O'; // Assume 'O' is the computer's move
        int score = _minimax(0, false); // Evaluate the score for this move
        grid[i] = ''; // Undo the move
        if (score > bestScore) { // Update best score and best move if needed
          bestScore = score;
          bestMove = i;
        }
      }
    }

    _saveState(); // Save current state before making a move
    setState(() {
      grid[bestMove] = 'O'; // Make the best move
      isX = true; // Switch back to player 'X'
      winner = _checkWinner(); // Check for a winner
    });
  }

  // Minimax algorithm to evaluate scores recursively
  int _minimax(int depth, bool isMaximizing) {
    String result = _checkWinner(); // Check for a winner
    if (result == 'O') return 10 - depth; // AI wins
    if (result == 'X') return depth - 10; // Human wins
    if (result == 'Draw') return 0; // Draw

    // Maximizing player's turn (AI)
    if (isMaximizing) {
      int bestScore = -1000; // Start with worst score
      for (int i = 0; i < grid.length; i++) {
        if (grid[i] == '') { // If the cell is empty
          grid[i] = 'O'; // AI's move
          int score = _minimax(depth + 1, false); // Evaluate the score
          grid[i] = ''; // Undo the move
          bestScore = max(score, bestScore); // Update best score
        }
      }
      return bestScore; // Return the best score found
    } else { // Minimizing player's turn (Human)
      int bestScore = 1000; // Start with worst score
      for (int i = 0; i < grid.length; i++) {
        if (grid[i] == '') { // If the cell is empty
          grid[i] = 'X'; // Human's move
          int score = _minimax(depth + 1, true); // Evaluate the score
          grid[i] = ''; // Undo the move
          bestScore = min(score, bestScore); // Update best score
        }
      }
      return bestScore; // Return the best score found
    }
  }

  // Check for a winner or draw
  String _checkWinner() {
    // Define winning combinations
    const List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6] // diagonals
    ];

    // Check each winning combination
    for (var combo in winningCombinations) {
      if (grid[combo[0]] != '' &&
          grid[combo[0]] == grid[combo[1]] &&
          grid[combo[1]] == grid[combo[2]]) {
        winningLine = combo; // Store the winning combination
        if (grid[combo[0]] == 'X') {
          xScore++; // Increment X's score
        } else {
          oScore++; // Increment O's score
        }
        return grid[combo[0]]; // Return the winner ('X' or 'O')
      }
    }

    // If no spots left, return draw and clear winning line
    if (!grid.contains('')) {
      winningLine = [];
      return 'Draw'; // Return 'Draw' if no spots are left
    }

    return ''; // Return empty if no winner yet
  }

  // Reset the game state
  void _resetGame() {
    setState(() {
      grid = List.generate(9, (_) => ''); // Reset the grid
      isX = true; // Reset player turn
      winner = ''; // Clear winner
      winningLine = []; // Clear the winning line
      moveHistory.clear(); // Clear the history on reset
    });
  }

  // Save the current game state for undo functionality
  void _saveState() {
    moveHistory.add(List.from(grid)); // Save a copy of the current grid state
  }

  // Undo the last move
  void _undoMove() {
    if (moveHistory.isNotEmpty) { // Check if there are moves to undo
      setState(() {
        grid = moveHistory.removeLast(); // Restore the last state
        isX = !isX; // Switch player back
        winner = _checkWinner(); // Check for a winner after undoing
        winningLine = []; // Clear the winning line when undoing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Game Mode Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton (
                  onPressed: () {
                    setState(() {
                      gameMode = 'Human vs Human'; // Set game mode to Human vs Human
                      _resetGame(); // Reset the game
                    });
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.purple), // Button color
                  child: const Text('Human vs Human'), // Button label
                ),
                const SizedBox(width: 20), // Space between buttons
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gameMode = 'Human vs Computer'; // Set game mode to Human vs Computer
                      _resetGame(); // Reset the game
                    });
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.purple), // Button color
                  child: const Text('Human vs Computer'), // Button label
                ),
              ],
            ),
            // Show difficulty level dropdown if playing against the computer
            if (gameMode == 'Human vs Computer')
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<String>(
                  value: difficultyLevel, // Currently selected difficulty
                  underline: Container(),
                  items: [
                    DropdownMenuItem(
                      value: 'Easy', // Easy difficulty option
                      child: Text('Easy'),
                    ),
                    DropdownMenuItem(
                      value: 'Hard', // Hard difficulty option
                      child: Text('Hard'),
                    ),
                  ],
                  onChanged: (String? newLevel) {
                    setState(() {
                      difficultyLevel = newLevel!; // Update difficulty level
                      _resetGame(); // Reset the game
                    });
                  },
                ),
              ),
            // Grid inside a SizedBox
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns for the grid
                  childAspectRatio: 1, // Aspect ratio of each grid cell
                ),
                itemCount: 9, // Total number of grid cells
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onTap(index), // Handle tap on the grid cell
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // Border color
                        color: winningLine.contains(index) && winner != ''
                            ? Colors.blue // Highlight winning line
                            : Colors.purple, // Default cell color
                      ),
                      child: Center(
                        child: Text(
                          grid[index], // Display 'X' or 'O'
                          style: TextStyle(
                            fontSize: 40, // Font size
                            fontWeight: FontWeight.bold, // Font weight
                            color: grid[index] == 'X'
                                ? Colors.yellow // Color for 'X'
                                : Colors.white, // Color for 'O'
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              winner == ''
                  ? 'Next player: ${isX ? 'X' : 'O'}' // Display next player
                  : winner == 'Draw'
                  ? 'It\'s a Draw!' // Display draw message
                  : '$winner Wins!', // Display winner message
              style: const TextStyle(fontSize: 20, color: Colors.white), // Text color for contrast
            ),
            Text(
              'Score: X - $xScore | O - $oScore',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetGame, // Reset game button
                  style: ElevatedButton.styleFrom(primary: Colors.red), // Button color
                  child: const Text('Reset'), // Button label
                ),
                const SizedBox(width: 20), // Space between buttons
                ElevatedButton(
                  onPressed: _undoMove, // Undo move button
                  style: ElevatedButton.styleFrom(primary: Colors.orange), // Button color
                  child: const Text('Undo'), // Button label
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black, // Set background color of the Scaffold
    );
  }
}