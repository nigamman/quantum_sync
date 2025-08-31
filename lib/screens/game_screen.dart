// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../services/game_logic_service.dart';
import '../services/game_data_service.dart';
import '../services/ad_service.dart';
import '../widgets/game_header.dart';
import '../widgets/stats_card.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_controls.dart';
import '../widgets/win_dialog.dart';
import '../widgets/progress_bar.dart';
import '../widgets/hint_dialog.dart';
import '../widgets/hint_result_dialog.dart';
import '../services/hint_service.dart';
import '../utils/app_theme.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState gameState;
  late AnimationController _celebrationController;
  late AnimationController _gridController;
  late AnimationController _buttonController;
  
  HintStatus? _hintStatus;
  bool _isLoadingHint = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeGame();
    _initializeAds();
  }

  void _setupAnimations() {
    _celebrationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _gridController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
  }

  Future<void> _initializeGame() async {
    final currentLevel = await GameDataService.getCurrentLevel();
    final bestScore = await GameDataService.getBestScore(currentLevel);
    final hintStatus = await HintService.getHintStatus();

    setState(() {
      gameState = GameState.fromLevel(currentLevel, bestScore);
      _hintStatus = hintStatus;
    });
  }

  Future<void> _initializeAds() async {
    // Initialize AdMob
    await AdService.initialize();
    
    // Preload a rewarded ad for hints
    AdService.loadRewardedAd();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _gridController.dispose();
    _buttonController.dispose();
    AdService.dispose();
    super.dispose();
  }

  void _onRotateRow(int rowIndex, int direction) {
    if (gameState.isComplete) return;

    _animateButton();
    HapticFeedback.lightImpact();

    setState(() {
      GameLogicService.rotateRow(gameState.grid, rowIndex, direction);
      gameState.moves++;
      _checkWin();
    });
  }

  void _onRotateColumn(int colIndex, int direction) {
    if (gameState.isComplete) return;

    _animateButton();
    HapticFeedback.lightImpact();

    setState(() {
      GameLogicService.rotateColumn(gameState.grid, colIndex, direction);
      gameState.moves++;
      _checkWin();
    });
  }

  void _checkWin() {
    if (GameLogicService.isComplete(gameState.grid, gameState.targetPattern)) {
      gameState.isComplete = true;
      _updateBestScore();
      _celebrationController.forward();
      HapticFeedback.mediumImpact();

      // Save progress
      GameDataService.saveProgress(gameState.currentLevel, gameState.moves);
    }
  }

  void _updateBestScore() {
    if (gameState.bestScore == null || gameState.moves < gameState.bestScore!) {
      gameState.bestScore = gameState.moves;
    }
  }

  void _animateButton() {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });
  }

  void _resetLevel() {
    setState(() {
      final levelData = GameLogicService.generateLevel(gameState.currentLevel);
      gameState.grid = levelData['initial'];
      gameState.moves = 0;
      gameState.isComplete = false;
      _celebrationController.reset();
    });
  }

  void _nextLevel() {
    if (gameState.currentLevel < 100) {
      setState(() {
        gameState.currentLevel++;
        final levelData = GameLogicService.generateLevel(gameState.currentLevel);
        gameState.grid = levelData['initial'];
        gameState.targetPattern = levelData['target'];
        gameState.moves = 0;
        gameState.isComplete = false;
        gameState.bestScore = null;
        _celebrationController.reset();
      });
    }
  }

  void _showHint() async {
    if (_hintStatus == null) return;
    
    // Show hint dialog first
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => HintDialog(
        hintStatus: _hintStatus!,
        onShowAd: _showAdForHint,
        onUseFreeHint: _useFreeHint,
        isLoading: _isLoadingHint,
      ),
    );
    
    if (result == true) {
      // Refresh hint status
      final newStatus = await HintService.getHintStatus();
      setState(() {
        _hintStatus = newStatus;
      });
    }
  }

  void _useFreeHint() async {
    if (_hintStatus == null || !_hintStatus!.hasFreeHints) return;
    
    setState(() {
      _isLoadingHint = true;
    });
    
    try {
      // Use the hint
      final success = await HintService.useHint();
      if (success) {
        // Generate and show hint
        final hint = HintService.generateHint(
          gameState.grid,
          gameState.targetPattern,
          gameState.currentLevel,
        );
        
        // Update hint status
        final newStatus = await HintService.getHintStatus();
        
        setState(() {
          _hintStatus = newStatus;
          _isLoadingHint = false;
        });
        
        // Show hint result
        _showHintResult(hint);
      }
    } catch (e) {
      setState(() {
        _isLoadingHint = false;
      });
    }
  }

  void _showAdForHint() async {
    setState(() {
      _isLoadingHint = true;
    });
    
    try {
      // Load ad if not ready
      if (!AdService.isAdReady) {
        final adLoaded = await AdService.loadRewardedAd();
        if (!adLoaded) {
          // Show error message if ad fails to load
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ad not available. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoadingHint = false;
          });
          return;
        }
      }
      
      // Show the rewarded ad
      final adCompleted = await AdService.showRewardedAd();
      
      if (adCompleted) {
        // Generate and show hint after successful ad completion
        final hint = HintService.generateHint(
          gameState.grid,
          gameState.targetPattern,
          gameState.currentLevel,
        );
        
        setState(() {
          _isLoadingHint = false;
        });
        
        // Show hint result
        _showHintResult(hint);
        
        // Preload next ad
        AdService.loadRewardedAd();
      } else {
        // Ad was not completed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please watch the full ad to get a hint.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoadingHint = false;
        });
      }
      
    } catch (e) {
      print('Error showing ad for hint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load ad. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoadingHint = false;
      });
    }
  }

  void _showHintResult(Hint hint) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HintResultDialog(
        hint: hint,
        currentGrid: gameState.grid, // Pass the current game grid
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                GameHeader(
                  level: gameState.currentLevel,
                  onBackPressed: () => Navigator.pop(context),
                  onHelpPressed: () => Navigator.pushNamed(context, '/instructions'),
                ),

                SizedBox(height: 16),

                // Stats
                StatsCard(
                  moves: gameState.moves,
                  bestScore: gameState.bestScore,
                  level: gameState.currentLevel,
                ),

                SizedBox(height: 24),

                // Target Pattern
                Text(
                  'TARGET PATTERN',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                GameGrid(
                  grid: gameState.targetPattern,
                  isTarget: true,
                  animationController: _gridController,
                ),

                SizedBox(height: 24),

                // Current Grid
                Text(
                  'CURRENT STATE',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                GameGrid(
                  grid: gameState.grid,
                  isTarget: false,
                  isComplete: gameState.isComplete,
                  animationController: _gridController,
                  onRotateRow: _onRotateRow,
                  onRotateColumn: _onRotateColumn,
                  buttonAnimationController: _buttonController,
                ),

                SizedBox(height: 24), // Replace Spacer() with fixed spacing

                // Win Dialog
                if (gameState.isComplete)
                  WinDialog(
                    level: gameState.currentLevel,
                    moves: gameState.moves,
                    isNewBest: gameState.bestScore == gameState.moves,
                    animationController: _celebrationController,
                    onNextLevel: _nextLevel,
                  ),

                // Game Controls
                GameControls(
                  onReset: _resetLevel,
                  onHint: _showHint,
                  isComplete: gameState.isComplete,
                  freeHintsRemaining: _hintStatus?.freeHintsRemaining ?? 0,
                ),

                SizedBox(height: 16),

                // Progress Bar
                ProgressBar(
                  currentLevel: gameState.currentLevel,
                  maxLevel: 100,
                ),

                SizedBox(height: 16), // Add bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}