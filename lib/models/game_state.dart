// lib/models/game_state.dart
import '../services/game_logic_service.dart';

class GameState {
  int currentLevel;
  List<List<int>> grid;
  List<List<int>> targetPattern;
  int moves;
  int? bestScore;
  bool isComplete;
  DateTime? startTime;
  String difficulty;
  int gridSize;

  GameState({
    required this.currentLevel,
    required this.grid,
    required this.targetPattern,
    this.moves = 0,
    this.bestScore,
    this.isComplete = false,
    this.startTime,
    required this.difficulty,
    required this.gridSize,
  });

  factory GameState.fromLevel(int level, int? bestScore) {
    final levelData = GameLogicService.generateLevel(level);
    final difficulty = GameLogicService.getDifficultyLabel(level);

    return GameState(
      currentLevel: level,
      grid: List<List<int>>.from(
          levelData['initial'].map((row) => List<int>.from(row))
      ),
      targetPattern: List<List<int>>.from(
          levelData['target'].map((row) => List<int>.from(row))
      ),
      bestScore: bestScore,
      startTime: DateTime.now(),
      difficulty: difficulty,
      gridSize: levelData['size'],
    );
  }

  // Calculate current session time
  Duration get sessionTime {
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime!);
  }

  // Get completion percentage for current level
  double get completionPercentage {
    final totalCells = gridSize * gridSize;
    int matchingCells = 0;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == targetPattern[i][j]) {
          matchingCells++;
        }
      }
    }

    return matchingCells / totalCells;
  }

  // Calculate efficiency score (lower is better)
  double get efficiencyScore {
    final theoreticalMin = GameLogicService.getTheoreticalMinMoves(currentLevel);
    if (moves == 0) return 0.0;
    return theoreticalMin / moves;
  }

  // Get current performance rating
  String get performanceRating {
    if (!isComplete) return 'In Progress';

    final efficiency = efficiencyScore;
    if (efficiency >= 0.9) return 'Perfect';
    if (efficiency >= 0.75) return 'Excellent';
    if (efficiency >= 0.6) return 'Good';
    if (efficiency >= 0.4) return 'Fair';
    return 'Needs Practice';
  }

  // Check if this is a new personal best
  bool get isNewPersonalBest {
    return isComplete && (bestScore == null || moves < bestScore!);
  }

  // Get hint based on current state
  String get contextualHint {
    return GameLogicService.getHint(currentLevel, grid, targetPattern);
  }

  // Create a copy of the current state (for undo functionality)
  GameState copyWith({
    int? currentLevel,
    List<List<int>>? grid,
    List<List<int>>? targetPattern,
    int? moves,
    int? bestScore,
    bool? isComplete,
    DateTime? startTime,
    String? difficulty,
    int? gridSize,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      grid: grid ?? List<List<int>>.from(this.grid.map((row) => List<int>.from(row))),
      targetPattern: targetPattern ?? List<List<int>>.from(this.targetPattern.map((row) => List<int>.from(row))),
      moves: moves ?? this.moves,
      bestScore: bestScore ?? this.bestScore,
      isComplete: isComplete ?? this.isComplete,
      startTime: startTime ?? this.startTime,
      difficulty: difficulty ?? this.difficulty,
      gridSize: gridSize ?? this.gridSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'grid': grid,
      'targetPattern': targetPattern,
      'moves': moves,
      'bestScore': bestScore,
      'isComplete': isComplete,
      'startTime': startTime?.toIso8601String(),
      'difficulty': difficulty,
      'gridSize': gridSize,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentLevel: json['currentLevel'],
      grid: List<List<int>>.from(json['grid'].map((row) => List<int>.from(row))),
      targetPattern: List<List<int>>.from(json['targetPattern'].map((row) => List<int>.from(row))),
      moves: json['moves'],
      bestScore: json['bestScore'],
      isComplete: json['isComplete'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      difficulty: json['difficulty'],
      gridSize: json['gridSize'],
    );
  }
}