// lib/widgets/win_dialog.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/app_theme.dart';

class WinDialog extends StatefulWidget {
  final int level;
  final int moves;
  final bool isNewBest;
  final AnimationController animationController;
  final VoidCallback onNextLevel;
  final List<String>? achievements;

  const WinDialog({
    Key? key,
    required this.level,
    required this.moves,
    required this.isNewBest,
    required this.animationController,
    required this.onNextLevel,
    this.achievements,
  }) : super(key: key);

  @override
  _WinDialogState createState() => _WinDialogState();
}

class _WinDialogState extends State<WinDialog>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _textController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<Particle> _particles = [];
  final int _particleCount = 50;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateParticles();
    _startAnimations();
  }

  void _setupAnimations() {
    _particleController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );


  }

  void _generateParticles() {
    final random = Random();
    
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble() * 400, // Default values, will be adjusted by ParticlePainter
          y: random.nextDouble() * 600,
          size: random.nextDouble() * 8 + 2,
          color: _getRandomColor(),
          velocity: random.nextDouble() * 2 + 1,
          angle: random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryPurple,
      AppTheme.primaryPink,
      AppTheme.accentGreen,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void _startAnimations() {
    _textController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 4 : 12,
      ),
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.75, // Reduced from 0.85
        maxWidth: screenSize.width * 0.95,
      ),
      child: Stack(
        children: [
          // Particle Background
          _buildParticleBackground(),

          // Main Win Dialog
          _buildMainDialog(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildParticleBackground() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animationValue: _particleController.value,
                maxX: constraints.maxWidth,
                maxY: constraints.maxHeight * 0.5, // Reduced from 0.6
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight * 0.5),
            );
          },
        );
      },
    );
  }

  Widget _buildMainDialog(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 50),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16), // Reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentGreen.withOpacity(0.2),
                    AppTheme.primaryPurple.withOpacity(0.2),
                    AppTheme.primaryPink.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentGreen.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGreen.withOpacity(0.3),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 150, // Reduced from 200
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Victory Icon
                        _buildVictoryIcon(isSmallScreen),

                        SizedBox(height: isSmallScreen ? 6 : 8), // Reduced spacing

                        // Victory Title
                        _buildVictoryTitle(isSmallScreen),

                        SizedBox(height: isSmallScreen ? 3 : 4), // Reduced spacing

                        // Stats
                        _buildStats(isSmallScreen),

                        SizedBox(height: isSmallScreen ? 6 : 8), // Reduced spacing

                        // Achievements
                        if (widget.achievements?.isNotEmpty ?? false)
                          _buildAchievements(isSmallScreen),

                        SizedBox(height: isSmallScreen ? 8 : 10), // Reduced spacing

                        // Action Buttons
                        _buildActionButtons(isSmallScreen),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVictoryIcon(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.animationController.value * 0.1,
          child: Transform.scale(
            scale: 1.0 + (widget.animationController.value * 0.2),
            child: Container(
              width: isSmallScreen ? 40 : 50, // Further reduced
              height: isSmallScreen ? 40 : 50, // Further reduced
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentGreen,
                    AppTheme.primaryPurple,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGreen.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                _getVictoryIcon(),
                color: Colors.white,
                size: isSmallScreen ? 20 : 25, // Further reduced
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getVictoryIcon() {
    if (widget.level >= 100) return Icons.emoji_events; // Trophy
    if (widget.level >= 75) return Icons.flash_on; // Lightning
    if (widget.level >= 50) return Icons.star; // Star
    if (widget.level >= 25) return Icons.check_circle; // Check
    return Icons.celebration; // Party
  }

  Widget _buildVictoryTitle(bool isSmallScreen) {
    String title = _getVictoryTitle();
    String subtitle = _getVictorySubtitle();

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppTheme.accentGreen, AppTheme.primaryPurple],
          ).createShader(bounds),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18, // Further reduced
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: isSmallScreen ? 1 : 2), // Further reduced
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 9 : 10, // Further reduced
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getVictoryTitle() {
    if (widget.level >= 100) return '🏆 QUANTUM GOD! 🏆';
    if (widget.level >= 75) return '⚡ LEGENDARY MASTER ⚡';
    if (widget.level >= 50) return '🔥 UNIVERSE BREAKER 🔥';
    if (widget.level >= 25) return '💫 MIND HACKER 💫';
    if (widget.level >= 10) return '🌟 QUANTUM SYNC! 🌟';
    return '✨ LEVEL COMPLETE! ✨';
  }

  String _getVictorySubtitle() {
    if (widget.level >= 100) return 'You have transcended reality itself!';
    if (widget.level >= 75) return 'You are among the 0.01% elite!';
    if (widget.level >= 50) return 'Few minds can reach this level!';
    if (widget.level >= 25) return 'Your brain is evolving!';
    return 'Quantum patterns aligned perfectly!';
  }

  Widget _buildStats(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 10), // Further reduced
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.touch_app,
            label: 'Moves',
            value: widget.moves.toString(),
            color: widget.isNewBest ? AppTheme.accentGreen : Colors.white,
            isSmallScreen: isSmallScreen,
          ),
          _buildStatItem(
            icon: Icons.flash_on,
            label: 'Level',
            value: widget.level.toString(),
            color: AppTheme.primaryPurple,
            isSmallScreen: isSmallScreen,
          ),
          if (widget.isNewBest)
            _buildStatItem(
              icon: Icons.star,
              label: 'New Best!',
              value: '🎉',
              color: AppTheme.accentGreen,
              isSmallScreen: isSmallScreen,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isSmallScreen ? 14 : 16), // Further reduced
        SizedBox(height: isSmallScreen ? 1 : 2), // Further reduced
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isSmallScreen ? 12 : 14, // Further reduced
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: isSmallScreen ? 8 : 9, // Further reduced
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8), // Further reduced
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '🎖️ NEW ACHIEVEMENTS!',
            style: TextStyle(
              color: Colors.amber,
              fontSize: isSmallScreen ? 11 : 12, // Further reduced
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 3 : 4), // Further reduced
          ...widget.achievements!.take(3).map((achievement) =>
              Padding(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 0.5 : 1), // Further reduced
                child: Text(
                  achievement,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 9 : 10, // Further reduced
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return Column(
      children: [
        // Next Level Button
        if (widget.level < 100)
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNextLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12), // Further reduced
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: AppTheme.primaryPurple.withOpacity(0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, size: isSmallScreen ? 14 : 16), // Further reduced
                  SizedBox(width: isSmallScreen ? 4 : 6), // Further reduced
                  Text(
                    'NEXT DIMENSION',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14, // Further reduced
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
        // Game Complete Message
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10), // Further reduced
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '👑 QUANTUM MASTER 👑',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 15, // Further reduced
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 1 : 2), // Further reduced
                Text(
                  'You have conquered all 100 levels!\nYou are truly one in a million!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 9 : 10, // Further reduced
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        SizedBox(height: isSmallScreen ? 6 : 8), // Reduced from 12

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8), // Further reduced
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'MENU',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13, // Added font size control
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 6 : 8), // Further reduced
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Share functionality would go here
                  _showShareDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink.withOpacity(0.5)),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8), // Further reduced
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'SHARE',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13, // Added font size control
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Your Achievement!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Just completed Level ${widget.level} in ${widget.moves} moves!',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              '🔥 Think you can beat my score in Quantum Sync? Only ${(100 - widget.level)}% of players reach this level!',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, this would trigger native sharing
              Navigator.pop(context);
            },
            child: Text('SHARE'),
          ),
        ],
      ),
    );
  }
}

// Particle system for celebration effect
class Particle {
  double x, y, size, velocity, angle;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.angle,
  });

  void update(double animationValue, {double maxX = 400, double maxY = 600}) {
    x += cos(angle) * velocity;
    y += sin(angle) * velocity + (animationValue * 2); // Gravity effect

    // Wrap around screen
    if (x < 0) x = maxX;
    if (x > maxX) x = 0;
    if (y > maxY) y = -10;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final double maxX;
  final double maxY;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.maxX,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      particle.update(animationValue, maxX: maxX, maxY: maxY);

      paint.color = particle.color.withOpacity(0.7);

      // Add glow effect
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );

      // Draw core particle
      paint.maskFilter = null;
      paint.color = particle.color;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 0.6,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}