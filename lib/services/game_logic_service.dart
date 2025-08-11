// lib/services/game_logic_service.dart
import 'dart:math';

class GameLogicService {
  // Generate a complete level with target and scrambled initial state
  static Map<String, dynamic> generateLevel(int level) {
    final size = _calculateGridSize(level);
    final complexity = _calculateComplexity(level);

    // Generate target pattern using mathematical sequences
    final target = _generateTargetPattern(size, level, complexity);

    // Create scrambled initial state
    final initial = _scramblePattern(target, level);

    // Calculate theoretical minimum moves
    final minMoves = getTheoreticalMinMoves(level);

    return {
      'initial': initial,
      'target': target,
      'size': size,
      'minMoves': minMoves,
      'complexity': complexity,
    };
  }

  // Calculate grid size based on level (3x3 to 6x6)
  static int _calculateGridSize(int level) {
    return min(3 + (level ~/ 15), 6);
  }

  // Calculate mathematical complexity for pattern generation
  static int _calculateComplexity(int level) {
    return (level * 1.3 + pow(level, 1.15)).round();
  }

  // Generate target pattern using mathematical rules
  static List<List<int>> _generateTargetPattern(int size, int level, int complexity) {
    final target = <List<int>>[];
    // Using deterministic seed for reproducible patterns

    for (int i = 0; i < size; i++) {
      final row = <int>[];
      for (int j = 0; j < size; j++) {
        int value;

        if (level <= 10) {
          // Simple arithmetic patterns
          value = (i + j + level) % 4;
        } else if (level <= 25) {
          // Geometric patterns
          value = (i * j + level * 2) % 4;
        } else if (level <= 50) {
          // Prime number based patterns
          value = ((i + 1) * (j + 1) * _getPrime(level % 7)) % 4;
        } else if (level <= 75) {
          // Fibonacci sequences
          value = (_fibonacci(i + j + (level % 8)) + complexity) % 4;
        } else {
          // Advanced mathematical sequences
          value = (_complexFunction(i, j, level, complexity)) % 4;
        }

        row.add(value);
      }
      target.add(row);
    }

    return target;
  }

  // Scramble the target pattern to create initial state
  static List<List<int>> _scramblePattern(List<List<int>> target, int level) {
    final scrambled = target.map((row) => List<int>.from(row)).toList();
    final size = scrambled.length;
    final scrambleCount = _calculateScrambleCount(level);
    final random = Random(level * 73); // Different seed for scrambling

    for (int s = 0; s < scrambleCount; s++) {
      final operation = random.nextInt(6);
      final index = random.nextInt(size);

      switch (operation) {
        case 0: rotateRow(scrambled, index, 1); break;
        case 1: rotateRow(scrambled, index, -1); break;
        case 2: rotateColumn(scrambled, index, 1); break;
        case 3: rotateColumn(scrambled, index, -1); break;
        case 4: _transformRow(scrambled, index); break;
        case 5: _transformColumn(scrambled, index); break;
      }
    }

    return scrambled;
  }

  // Calculate number of scrambling operations
  static int _calculateScrambleCount(int level) {
    return min((level * 2.2 + pow(level, 1.08)).round(), 150);
  }

  // Rotate row left or right
  static void rotateRow(List<List<int>> grid, int rowIndex, int direction) {
    if (rowIndex >= grid.length) return;

    final row = grid[rowIndex];
    if (row.isEmpty) return;

    // Apply color transformation during rotation
    for (int i = 0; i < row.length; i++) {
      row[i] = _transformColor(row[i], rowIndex, i, direction);
    }

    // Perform rotation
    if (direction > 0) {
      final last = row.removeLast();
      row.insert(0, last);
    } else {
      final first = row.removeAt(0);
      row.add(first);
    }
  }

  // Rotate column up or down
  static void rotateColumn(List<List<int>> grid, int colIndex, int direction) {
    if (grid.isEmpty || colIndex >= grid[0].length) return;

    final column = grid.map((row) => row[colIndex]).toList();
    if (column.isEmpty) return;

    // Apply color transformation during rotation
    for (int i = 0; i < column.length; i++) {
      column[i] = _transformColor(column[i], i, colIndex, direction);
    }

    // Perform rotation
    if (direction > 0) {
      final last = column.removeLast();
      column.insert(0, last);
    } else {
      final first = column.removeAt(0);
      column.add(first);
    }

    // Update grid with transformed column
    for (int i = 0; i < column.length; i++) {
      grid[i][colIndex] = column[i];
    }
  }

  // Transform colors during row operations
  static void _transformRow(List<List<int>> grid, int rowIndex) {
    if (rowIndex >= grid.length) return;
    for (int j = 0; j < grid[rowIndex].length; j++) {
      grid[rowIndex][j] = (grid[rowIndex][j] + 1) % 4;
    }
  }

  // Transform colors during column operations
  static void _transformColumn(List<List<int>> grid, int colIndex) {
    if (grid.isEmpty || colIndex >= grid[0].length) return;
    for (int i = 0; i < grid.length; i++) {
      grid[i][colIndex] = (grid[i][colIndex] + 1) % 4;
    }
  }

  // Color transformation function (the secret sauce!)
  static int _transformColor(int color, int row, int col, int direction) {
    // Complex transformation that makes the puzzle challenging
    final base = (color + direction + row + col) % 4;
    final modifier = ((row * col + direction * 2) % 3);
    return (base + modifier) % 4;
  }

  // Check if puzzle is complete
  static bool isComplete(List<List<int>> current, List<List<int>> target) {
    if (current.length != target.length) return false;

    for (int i = 0; i < current.length; i++) {
      if (current[i].length != target[i].length) return false;
      for (int j = 0; j < current[i].length; j++) {
        if (current[i][j] != target[i][j]) return false;
      }
    }
    return true;
  }

  // Get theoretical minimum moves for a level
  static int getTheoreticalMinMoves(int level) {
    final size = _calculateGridSize(level);
    return ((level * 0.7) + (size * 1.1) + sqrt(level * 2)).round();
  }

  // Mathematical helper functions
  static int _getPrime(int index) {
    const primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29];
    return primes[index % primes.length];
  }

  static int _fibonacci(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
      int temp = a + b;
      a = b;
      b = temp;
    }
    return b;
  }

  static int _complexFunction(int i, int j, int level, int complexity) {
    // Advanced mathematical function for high levels
    final base = pow(i + 1, 1.5) + pow(j + 1, 1.3);
    final modifier = sin((level * pi) / 180) * complexity;
    return (base + modifier).round();
  }

  // Difficulty and hint system
  static String getDifficultyLabel(int level) {
    if (level <= 5) return 'Quantum Initiation';
    if (level <= 15) return 'Reality Bending';
    if (level <= 30) return 'Mind Fracturing';
    if (level <= 50) return 'Universe Breaking';
    if (level <= 75) return 'Legendary Nightmare';
    return 'Quantum God Mode';
  }

  static String getDifficultyDescription(int level) {
    if (level <= 5) return 'Learning quantum basics';
    if (level <= 15) return 'Your brain is adapting';
    if (level <= 30) return 'Entering dangerous territory';
    if (level <= 50) return 'Few minds survive here';
    if (level <= 75) return 'You are among the elite';
    return 'You have transcended reality';
  }

  static String getHint(int level, List<List<int>> current, List<List<int>> target) {
    final size = current.length;
    int differentCells = 0;

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (current[i][j] != target[i][j]) differentCells++;
      }
    }

    final hints = <String>[];

    if (level <= 10) {
      hints.addAll([
        '🎯 Focus on one row at a time - get it perfect before moving on',
        '🔄 Remember: colors change when you rotate! Blue might become red',
        '⚡ Try working from the corners - they\'re easier to control',
        '🧠 Count your rotations: 4 rotations = back to original position',
      ]);
    } else if (level <= 30) {
      hints.addAll([
        '🔍 Look for patterns in the target - is it symmetric?',
        '📐 Mathematical approach: work in sequences, not individual moves',
        '⏮️ Sometimes you need to "break" progress to make real progress',
        '🎲 This level needs about ${getTheoreticalMinMoves(level)} optimal moves',
      ]);
    } else if (level <= 60) {
      hints.addAll([
        '🚀 Advanced technique: Use "setup moves" to position pieces',
        '⚛️ Think like an algorithm - plan 4-5 moves ahead',
        '🎯 Only $differentCells cells are wrong - be surgical with moves',
        '🔬 Look for mathematical relationships between positions',
      ]);
    } else {
      hints.addAll([
        '🌌 Master level: Every move must serve a specific purpose',
        '🧮 Use paper to map out your move sequence',
        '⚡ At this level, intuition must become calculation',
        '🏆 You\'re in the top 1% just by reaching this level!',
      ]);
    }

    return hints[Random().nextInt(hints.length)];
  }

  // Color helper for UI
  static int getCellColorValue(int value) {
    return value % 4; // Ensure valid color range
  }
}