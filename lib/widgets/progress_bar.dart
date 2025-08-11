// lib/widgets/progress_bar.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'dart:math';

class ProgressBar extends StatefulWidget {
  final int currentLevel;
  final int maxLevel;
  final bool showMilestones;
  final bool animated;

  const ProgressBar({
    Key? key,
    required this.currentLevel,
    required this.maxLevel,
    this.showMilestones = true,
    this.animated = true,
  }) : super(key: key);

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.animated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentLevel / widget.maxLevel,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLevel != widget.currentLevel) {
      _setupAnimations();
      if (widget.animated) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        _buildProgressBar(),

        SizedBox(height: 8),

        // Progress Text
        _buildProgressText(),

        if (widget.showMilestones) ...[
          SizedBox(height: 12),
          _buildMilestones(),
        ],
      ],
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Background
                Container(
                  width: double.infinity,
                  color: Colors.grey[800],
                ),

                // Progress Fill
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _getProgressGradient(),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(
                              _glowAnimation.value * 0.5
                          ),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Animated Shine Effect
                if (widget.animated)
                  _buildShineEffect(),
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getProgressGradient() {
    final progress = widget.currentLevel / widget.maxLevel;

    if (progress < 0.2) {
      return LinearGradient(
        colors: [Colors.blue[400]!, Colors.blue[600]!],
      );
    } else if (progress < 0.5) {
      return LinearGradient(
        colors: [AppTheme.primaryPurple, Colors.purple[700]!],
      );
    } else if (progress < 0.8) {
      return LinearGradient(
        colors: [Colors.orange[400]!, Colors.red[600]!],
      );
    } else {
      return LinearGradient(
        colors: [Colors.amber[400]!, Colors.amber.shade50],
      );
    }
  }

  Widget _buildShineEffect() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: (_progressAnimation.value * 300) - 50,
          child: Container(
            width: 50,
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getProgressDescription(),
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        Text(
          '${widget.currentLevel}/${widget.maxLevel}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getProgressDescription() {
    final progress = widget.currentLevel / widget.maxLevel;

    if (progress < 0.1) return "The quantum journey begins...";
    if (progress < 0.25) return "Learning the quantum basics";
    if (progress < 0.5) return "Your mind is adapting";
    if (progress < 0.75) return "Entering dangerous territory";
    if (progress < 0.95) return "Few have reached this far";
    return "You're in uncharted quantum space";
  }

  Widget _buildMilestones() {
    final milestones = [5, 10, 25, 50, 75, 100];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: milestones.map((milestone) =>
          _buildMilestoneMarker(milestone)
      ).toList(),
    );
  }

  Widget _buildMilestoneMarker(int milestone) {
    final isReached = widget.currentLevel >= milestone;
    final isCurrent = widget.currentLevel == milestone;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isCurrent ? 24 : 16,
      height: isCurrent ? 24 : 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isReached
            ? _getMilestoneColor(milestone)
            : Colors.grey[600],
        border: Border.all(
          color: isCurrent
              ? Colors.white
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: isReached ? [
          BoxShadow(
            color: _getMilestoneColor(milestone).withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ] : [],
      ),
      child: Center(
        child: Icon(
          _getMilestoneIcon(milestone),
          color: isReached ? Colors.white : Colors.white54,
          size: isCurrent ? 14 : 10,
        ),
      ),
    );
  }

  Color _getMilestoneColor(int milestone) {
    switch (milestone) {
      case 5: return Colors.blue;
      case 10: return AppTheme.primaryPurple;
      case 25: return Colors.orange;
      case 50: return Colors.red;
      case 75: return Colors.amber;
      case 100: return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getMilestoneIcon(int milestone) {
    switch (milestone) {
      case 5: return Icons.auto_awesome;
      case 10: return Icons.psychology;
      case 25: return Icons.bolt;
      case 50: return Icons.rocket_launch;
      case 75: return Icons.emoji_events;
      case 100: return Icons.workspace_premium;
      default: return Icons.circle;
    }
  }
}

class CircularProgressBar extends StatefulWidget {
  final int currentLevel;
  final int maxLevel;
  final double size;
  final bool showPercentage;

  const CircularProgressBar({
    Key? key,
    required this.currentLevel,
    required this.maxLevel,
    this.size = 120,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  _CircularProgressBarState createState() => _CircularProgressBarState();
}

class _CircularProgressBarState extends State<CircularProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.currentLevel / widget.maxLevel,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: CircularProgressPainter(
              progress: _animation.value,
              strokeWidth: 8.0,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Level',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${widget.currentLevel}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.showPercentage)
                    Text(
                      '${(_animation.value * 100).toInt()}%',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    this.strokeWidth = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = AppTheme.primaryPurple.withOpacity(0.3)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}