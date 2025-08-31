// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_logo.dart';
import '../widgets/menu_button.dart';
import '../widgets/warning_card.dart';
import '../services/game_data_service.dart';
import 'settings_screen.dart'; // Added import for SettingsScreen

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  int currentLevel = 1;
  int gamesCompleted = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
    _loadUserProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh progress when screen becomes active
    _loadUserProgress();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh progress when app is resumed
      _loadUserProgress();
    }
  }

  Future<void> _loadUserProgress() async {
    final stats = await GameDataService.getGameStats();
    setState(() {
      currentLevel = stats['currentLevel'] ?? 1;
      gamesCompleted = stats['gamesCompleted'] ?? 0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48.0, // Account for padding
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top spacing - flexible on smaller screens
                        SizedBox(height: constraints.maxHeight > 700 ? 40 : 20),

                        // Logo Section
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -50 * (1 - _animationController.value)),
                              child: Opacity(
                                opacity: _animationController.value,
                                child: Column(
                                  children: [
                                    AnimatedLogo(size: constraints.maxHeight > 700 ? 100 : 80),
                                    SizedBox(height: constraints.maxHeight > 700 ? 24 : 16),
                                    ShaderMask(
                                      shaderCallback: (bounds) => AppTheme.buttonGradient.createShader(bounds),
                                      child: Text(
                                        'QUANTUM SYNC',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontSize: constraints.maxHeight > 700 ? null : 24,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '100 Levels of Pure Logic',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white70,
                                        fontSize: constraints.maxHeight > 700 ? null : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: constraints.maxHeight > 700 ? 40 : 24),

                        // User Progress Card
                        if (currentLevel > 1)
                          Padding(
                            padding: EdgeInsets.only(bottom: constraints.maxHeight > 700 ? 40 : 24),
                            child: _buildProgressCard(),
                          ),

                        // Menu Buttons
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - _animationController.value)),
                              child: Opacity(
                                opacity: _animationController.value,
                                child: Column(
                                  children: [
                                    MenuButton(
                                      text: currentLevel == 1 ? 'START GAME' : 'CONTINUE GAME',
                                      icon: Icons.play_arrow,
                                      onPressed: () => Navigator.pushNamed(context, '/game'),
                                      isPrimary: true,
                                    ),
                                    SizedBox(height: 16),
                                    MenuButton(
                                      text: 'HOW TO PLAY',
                                      icon: Icons.help_outline,
                                      onPressed: () => Navigator.pushNamed(context, '/instructions'),
                                    ),
                                    SizedBox(height: 16),
                                    MenuButton(
                                      text: 'LEVELS',
                                      icon: Icons.grid_view,
                                      onPressed: () => _showLevelsDialog(),
                                    ),
                                    SizedBox(height: 16),
                                    MenuButton(
                                      text: 'SETTINGS',
                                      icon: Icons.settings,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SettingsScreen(
                                            onDataDeleted: () {
                                              // Refresh progress when data is deleted
                                              _loadUserProgress();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Flexible spacing
                        SizedBox(height: constraints.maxHeight > 700 ? 40 : 24),

                        // Warning Card
                        WarningCard(),

                        // Bottom spacing
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration.copyWith(
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGreen,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Level', currentLevel.toString(), Icons.flash_on),
              _buildStatItem('Completed', gamesCompleted.toString(), Icons.check_circle),
              _buildStatItem('Progress', '${(currentLevel / 100 * 100).toInt()}%', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Flexible(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentGreen, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLevelsDialog() async {
    final completedLevels = await GameDataService.getCompletedLevels();
    final currentLevel = await GameDataService.getCurrentLevel();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryPurple,
        title: Text('Select Level', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 100,
            itemBuilder: (context, index) {
              final level = index + 1;
              final isCompleted = completedLevels.contains(level);
              final isCurrentLevel = level == currentLevel;
              
              return FutureBuilder<bool>(
                future: GameDataService.isLevelUnlocked(level),
                builder: (context, snapshot) {
                  final isUnlocked = level == 1 || (snapshot.data ?? false);
                  
                  return GestureDetector(
                    onTap: isUnlocked ? () {
                      Navigator.pop(context);
                      // Set the selected level and navigate to game
                      GameDataService.setCurrentLevel(level).then((_) {
                        Navigator.pushNamed(context, '/game');
                      });
                    } : () {
                      // Show message for locked level
                      _showLevelLockedMessage(level, completedLevels);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted 
                          ? AppTheme.accentGreen
                          : isUnlocked 
                            ? (isCurrentLevel ? AppTheme.primaryPink : AppTheme.primaryPurple)
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrentLevel 
                          ? Border.all(color: AppTheme.accentGreen, width: 2)
                          : null,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              level.toString(),
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.grey,
                                fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            if (isCompleted)
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 12,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showLevelLockedMessage(int level, List<int> completedLevels) {
    final nextLevelToComplete = completedLevels.isEmpty ? 1 : completedLevels.reduce((a, b) => a > b ? a : b) + 1;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryPurple,
        title: Row(
          children: [
            Icon(Icons.lock, color: AppTheme.primaryPink),
            SizedBox(width: 8),
            Text('Level $level Locked', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Complete Level $nextLevelToComplete first to unlock Level $level!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.accentGreen)),
          ),
        ],
      ),
    );
  }
}