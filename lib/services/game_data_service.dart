// lib/services/game_data_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GameDataService {
  // Keys for SharedPreferences
  static const String _currentLevelKey = 'current_level';
  static const String _bestScoresKey = 'best_scores';
  static const String _totalPlayTimeKey = 'total_play_time';
  static const String _gamesCompletedKey = 'games_completed';
  static const String _gameStatsKey = 'game_stats';
  static const String _achievementsKey = 'achievements';
  static const String _settingsKey = 'settings';

  // Save game progress
  static Future<void> saveProgress(int level, int moves) async {
    final prefs = await SharedPreferences.getInstance();

    // Update current level if completed
    final currentLevel = prefs.getInt(_currentLevelKey) ?? 1;
    if (level >= currentLevel) {
      await prefs.setInt(_currentLevelKey, level + 1);
    }

    // Update best score for this level
    final bestScores = await _getBestScoresList();
    while (bestScores.length <= level) {
      bestScores.add(0);
    }

    if (bestScores[level] == 0 || moves < bestScores[level]) {
      bestScores[level] = moves;
      await _saveBestScoresList(bestScores);
    }

    // Update completion count
    final completed = prefs.getInt(_gamesCompletedKey) ?? 0;
    await prefs.setInt(_gamesCompletedKey, completed + 1);

    // Update detailed stats
    await _updateDetailedStats(level, moves);
  }

  // Get current level
  static Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentLevelKey) ?? 1;
  }

  // Get completed levels (levels that have been solved)
  static Future<List<int>> getCompletedLevels() async {
    final bestScores = await _getBestScoresList();
    final completedLevels = <int>[];
    
    for (int i = 0; i < bestScores.length; i++) {
      if (bestScores[i] > 0) {
        completedLevels.add(i + 1); // Convert to 1-based level numbers
      }
    }
    
    return completedLevels;
  }

  // Check if a level is unlocked (can be played)
  static Future<bool> isLevelUnlocked(int level) async {
    if (level == 1) return true; // Level 1 is always unlocked
    
    final completedLevels = await getCompletedLevels();
    if (completedLevels.isEmpty) return false; // No levels completed, only level 1 unlocked
    
    final maxCompletedLevel = completedLevels.reduce((a, b) => a > b ? a : b);
    
    // Level is unlocked if it's the next level after the highest completed level
    return level == maxCompletedLevel + 1;
  }

  // Set current level (for level selection)
  static Future<void> setCurrentLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentLevelKey, level);
  }

  // Get best score for specific level
  static Future<int?> getBestScore(int level) async {
    final bestScores = await _getBestScoresList();
    if (level < bestScores.length && bestScores[level] > 0) {
      return bestScores[level];
    }
    return null;
  }

  // Get all best scores
  static Future<List<int>> _getBestScoresList() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = prefs.getString(_bestScoresKey);
    if (scoresJson != null) {
      final List<dynamic> decoded = json.decode(scoresJson);
      return decoded.cast<int>();
    }
    return <int>[];
  }

  // Save best scores list
  static Future<void> _saveBestScoresList(List<int> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bestScoresKey, json.encode(scores));
  }

  // Get comprehensive game statistics
  static Future<Map<String, int>> getGameStats() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'currentLevel': prefs.getInt(_currentLevelKey) ?? 1,
      'gamesCompleted': prefs.getInt(_gamesCompletedKey) ?? 0,
      'totalPlayTime': prefs.getInt(_totalPlayTimeKey) ?? 0,
    };
  }

  // Update detailed statistics
  static Future<void> _updateDetailedStats(int level, int moves) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_gameStatsKey);

    Map<String, dynamic> stats = {};
    if (statsJson != null) {
      stats = json.decode(statsJson);
    }

    // Initialize stats if first time
    stats['totalMoves'] = (stats['totalMoves'] ?? 0) + moves;
    stats['averageMoves'] = stats['totalMoves'] / ((stats['gamesCompleted'] ?? 0) + 1);
    stats['highestLevel'] = level > (stats['highestLevel'] ?? 0) ? level : stats['highestLevel'];
    stats['gamesCompleted'] = (stats['gamesCompleted'] ?? 0) + 1;
    stats['lastPlayedDate'] = DateTime.now().toIso8601String();

    // Track level completion times
    final levelCompletions = Map<String, int>.from(stats['levelCompletions'] ?? {});
    levelCompletions[level.toString()] = (levelCompletions[level.toString()] ?? 0) + 1;
    stats['levelCompletions'] = levelCompletions;

    await prefs.setString(_gameStatsKey, json.encode(stats));
  }

  // Achievement system
  static Future<List<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);
    if (achievementsJson != null) {
      final List<dynamic> decoded = json.decode(achievementsJson);
      return decoded.cast<String>();
    }
    return <String>[];
  }

  static Future<List<String>> checkAndUnlockAchievements(int level, int moves, int? previousBest) async {
    final achievements = await getUnlockedAchievements();
    final newAchievements = <String>[];

    // Level milestones
    final levelMilestones = {
      5: '🌟 Quantum Apprentice',
      10: '⚡ Reality Bender',
      25: '💫 Mind Hacker',
      50: '🔥 Universe Breaker',
      75: '👑 Legendary Master',
      100: '🏆 Quantum God',
    };

    levelMilestones.forEach((milestone, achievement) {
      if (level >= milestone && !achievements.contains(achievement)) {
        achievements.add(achievement);
        newAchievements.add(achievement);
      }
    });

    // Performance achievements
    if (previousBest != null && moves < previousBest) {
      final improvement = '📈 Personal Best: Level $level';
      if (!achievements.contains(improvement)) {
        achievements.add(improvement);
        newAchievements.add(improvement);
      }
    }

    // Special achievements
    if (moves <= 10 && level > 10) {
      final perfect = '💎 Perfect Solution: Level $level';
      if (!achievements.contains(perfect)) {
        achievements.add(perfect);
        newAchievements.add(perfect);
      }
    }

    // Save updated achievements
    if (newAchievements.isNotEmpty) {
      await _saveAchievements(achievements);
    }

    return newAchievements;
  }

  static Future<void> _saveAchievements(List<String> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_achievementsKey, json.encode(achievements));
  }

  // Settings management
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      return json.decode(settingsJson);
    }

    // Default settings
    return {
      'soundEnabled': true,
      'hapticFeedback': true,
      'showHints': true,
      'animationSpeed': 1.0,
      'colorBlindMode': false,
    };
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    final settings = await getSettings();
    settings[key] = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings));
  }

  // Analytics data (for app optimization)
  static Future<void> logGameSession(int level, int moves, int timeSpent, bool completed) async {
    final prefs = await SharedPreferences.getInstance();

    // Update total play time
    final totalTime = prefs.getInt(_totalPlayTimeKey) ?? 0;
    await prefs.setInt(_totalPlayTimeKey, totalTime + timeSpent);

    // Log session data (would send to analytics service in production)
    final sessionData = {
      'level': level,
      'moves': moves,
      'timeSpent': timeSpent,
      'completed': completed,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Store last 50 sessions locally for debugging
    final sessions = await _getRecentSessions();
    sessions.add(sessionData);
    if (sessions.length > 50) {
      sessions.removeAt(0);
    }
    await _saveRecentSessions(sessions);
  }

  static Future<List<Map<String, dynamic>>> _getRecentSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('recent_sessions');
    if (sessionsJson != null) {
      final List<dynamic> decoded = json.decode(sessionsJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  static Future<void> _saveRecentSessions(List<Map<String, dynamic>> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_sessions', json.encode(sessions));
  }

  // Data export/import for cloud sync (future feature)
  static Future<String> exportGameData() async {
    final prefs = await SharedPreferences.getInstance();

    final gameData = {
      'currentLevel': prefs.getInt(_currentLevelKey),
      'bestScores': prefs.getString(_bestScoresKey),
      'totalPlayTime': prefs.getInt(_totalPlayTimeKey),
      'gamesCompleted': prefs.getInt(_gamesCompletedKey),
      'gameStats': prefs.getString(_gameStatsKey),
      'achievements': prefs.getString(_achievementsKey),
      'settings': prefs.getString(_settingsKey),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };

    return json.encode(gameData);
  }

  static Future<bool> importGameData(String gameDataJson) async {
    try {
      final gameData = json.decode(gameDataJson);
      final prefs = await SharedPreferences.getInstance();

      // Validate data structure
      if (gameData['version'] == null) return false;

      // Import data
      if (gameData['currentLevel'] != null) {
        await prefs.setInt(_currentLevelKey, gameData['currentLevel']);
      }
      if (gameData['bestScores'] != null) {
        await prefs.setString(_bestScoresKey, gameData['bestScores']);
      }
      if (gameData['totalPlayTime'] != null) {
        await prefs.setInt(_totalPlayTimeKey, gameData['totalPlayTime']);
      }
      if (gameData['gamesCompleted'] != null) {
        await prefs.setInt(_gamesCompletedKey, gameData['gamesCompleted']);
      }
      if (gameData['gameStats'] != null) {
        await prefs.setString(_gameStatsKey, gameData['gameStats']);
      }
      if (gameData['achievements'] != null) {
        await prefs.setString(_achievementsKey, gameData['achievements']);
      }
      if (gameData['settings'] != null) {
        await prefs.setString(_settingsKey, gameData['settings']);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset all game data
  static Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_currentLevelKey);
    await prefs.remove(_bestScoresKey);
    await prefs.remove(_totalPlayTimeKey);
    await prefs.remove(_gamesCompletedKey);
    await prefs.remove(_gameStatsKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove('recent_sessions');
  }

  // Get leaderboard data (simulated - would be real server in production)
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Generate fake leaderboard data
    final leaderboard = <Map<String, dynamic>>[];
    final currentStats = await getGameStats();

    // Add user to leaderboard
    leaderboard.add({
      'rank': 1,
      'username': 'You',
      'level': currentStats['currentLevel'],
      'totalMoves': 0, // Would calculate from best scores
      'isCurrentUser': true,
    });

    // Add fake competitors
    for (int i = 2; i <= 20; i++) {
      leaderboard.add({
        'rank': i,
        'username': 'QuantumMaster${1000 + (i * 47)}',
        'level': (100 - (i * 3)).clamp(1, 100),
        'totalMoves': 1000 + (i * 150),
        'isCurrentUser': false,
      });
    }

    return leaderboard;
  }
}