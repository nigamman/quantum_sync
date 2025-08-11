// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_logo.dart';
import '../widgets/menu_button.dart';
import '../widgets/warning_card.dart';
import '../services/game_data_service.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int currentLevel = 1;
  int gamesCompleted = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
    _loadUserProgress();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                            AnimatedLogo(size: 100),
                            SizedBox(height: 24),
                            ShaderMask(
                              shaderCallback: (bounds) => AppTheme.buttonGradient.createShader(bounds),
                              child: Text(
                                'QUANTUM SYNC',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '100 Levels of Pure Logic',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 40),

                // User Progress Card
                if (currentLevel > 1) _buildProgressCard(),

                SizedBox(height: 40),

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
                              text: 'LEADERBOARD',
                              icon: Icons.leaderboard,
                              onPressed: () => _showComingSoon('Leaderboard'),
                            ),
                            SizedBox(height: 16),
                            MenuButton(
                              text: 'SETTINGS',
                              icon: Icons.settings,
                              onPressed: () => _showComingSoon('Settings'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 40),

                // Warning Card
                WarningCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
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
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryPurple, size: 24),
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
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon', style: TextStyle(color: Colors.white)),
        content: Text(
          '$feature feature will be available in the next update!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }
}