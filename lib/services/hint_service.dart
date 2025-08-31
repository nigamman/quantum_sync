// lib/services/hint_service.dart
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class HintService {
  static const String _hintsUsedKey = 'hints_used_today';
  static const String _lastResetDateKey = 'last_hint_reset_date';
  static const int _dailyFreeHints = 3;
  
  // Get current hint availability
  static Future<HintStatus> getHintStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString(_lastResetDateKey) ?? '';
    final hintsUsed = prefs.getInt(_hintsUsedKey) ?? 0;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Reset hints if it's a new day
    if (lastResetDate != today) {
      await prefs.setString(_lastResetDateKey, today);
      await prefs.setInt(_hintsUsedKey, 0);
      return HintStatus(
        freeHintsRemaining: _dailyFreeHints,
        totalHintsUsed: 0,
        lastResetDate: today,
      );
    }
    
    return HintStatus(
      freeHintsRemaining: max(0, _dailyFreeHints - hintsUsed),
      totalHintsUsed: hintsUsed,
      lastResetDate: lastResetDate,
    );
  }
  
  // Use a hint (increment counter)
  static Future<bool> useHint() async {
    final prefs = await SharedPreferences.getInstance();
    final hintsUsed = prefs.getInt(_hintsUsedKey) ?? 0;
    
    if (hintsUsed >= _dailyFreeHints) {
      return false; // No free hints left
    }
    
    await prefs.setInt(_hintsUsedKey, hintsUsed + 1);
    return true;
  }
  
  // Generate a hint for the current game state
  static Hint generateHint(List<List<int>> currentGrid, List<List<int>> targetGrid, int level) {
    final moves = _findOptimalMoves(currentGrid, targetGrid, level);
    
    if (moves.isEmpty) {
      return Hint(
        type: HintType.noHint,
        message: "You're on the right track! Keep trying different combinations.",
        move: null,
      );
    }
    
    final move = moves.first;
    String message;
    
    switch (move.type) {
      case MoveType.rowLeft:
        message = "Try rotating row ${move.index + 1} to the left";
        break;
      case MoveType.rowRight:
        message = "Try rotating row ${move.index + 1} to the right";
        break;
      case MoveType.columnUp:
        message = "Try rotating column ${move.index + 1} upward";
        break;
      case MoveType.columnDown:
        message = "Try rotating column ${move.index + 1} downward";
        break;
    }
    
    return Hint(
      type: HintType.move,
      message: message,
      move: move,
    );
  }
  
  // Find optimal moves using a simplified algorithm
  static List<Move> _findOptimalMoves(List<List<int>> current, List<List<int>> target, int level) {
    final moves = <Move>[];
    final size = current.length;
    
    // Simple heuristic: look for rows/columns that are close to being solved
    for (int i = 0; i < size; i++) {
      // Check row similarity
      int rowMatches = 0;
      for (int j = 0; j < size; j++) {
        if (current[i][j] == target[i][j]) rowMatches++;
      }
      
      if (rowMatches >= size - 1) {
        // Row is almost solved, suggest a rotation
        moves.add(Move(type: MoveType.rowLeft, index: i));
        moves.add(Move(type: MoveType.rowRight, index: i));
      }
      
      // Check column similarity
      int colMatches = 0;
      for (int j = 0; j < size; j++) {
        if (current[j][i] == target[j][i]) colMatches++;
      }
      
      if (colMatches >= size - 1) {
        // Column is almost solved, suggest a rotation
        moves.add(Move(type: MoveType.columnUp, index: i));
        moves.add(Move(type: MoveType.columnDown, index: i));
      }
    }
    
    // If no obvious moves, suggest random moves based on level
    if (moves.isEmpty) {
      final random = Random(level);
      final moveType = MoveType.values[random.nextInt(MoveType.values.length)];
      final index = random.nextInt(size);
      moves.add(Move(type: moveType, index: index));
    }
    
    return moves.take(2).toList(); // Return max 2 suggestions
  }
}

class HintStatus {
  final int freeHintsRemaining;
  final int totalHintsUsed;
  final String lastResetDate;
  
  HintStatus({
    required this.freeHintsRemaining,
    required this.totalHintsUsed,
    required this.lastResetDate,
  });
  
  bool get hasFreeHints => freeHintsRemaining > 0;
  bool get needsAd => !hasFreeHints;
}

class Hint {
  final HintType type;
  final String message;
  final Move? move;
  
  Hint({
    required this.type,
    required this.message,
    this.move,
  });
}

enum HintType {
  move,
  noHint,
}

class Move {
  final MoveType type;
  final int index;
  
  Move({
    required this.type,
    required this.index,
  });
}

enum MoveType {
  rowLeft,
  rowRight,
  columnUp,
  columnDown,
}
