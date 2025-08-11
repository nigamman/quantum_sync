// lib/widgets/game_controls.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onHint;
  final bool isComplete;
  final int freeHintsRemaining;

  const GameControls({
    Key? key,
    required this.onReset,
    required this.onHint,
    this.isComplete = false,
    this.freeHintsRemaining = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Reset Button
        Expanded(
          child: _buildControlButton(
            context: context,
            icon: Icons.refresh,
            label: 'RESET',
            onPressed: onReset,
            isPrimary: false,
            color: Colors.white.withOpacity(0.1),
            textColor: Colors.white,
            iconColor: Colors.white70,
          ),
        ),

        SizedBox(width: 12),

        // Hint Button
        Expanded(
          child: _buildControlButton(
            context: context,
            icon: Icons.lightbulb_outline,
            label: freeHintsRemaining > 0 ? 'HINT ($freeHintsRemaining)' : 'HINT',
            onPressed: isComplete ? null : onHint, // Disable when complete
            isPrimary: false,
            color: freeHintsRemaining > 0 
                ? AppTheme.primaryPurple.withOpacity(0.3)
                : AppTheme.primaryPurple.withOpacity(0.2),
            textColor: Colors.white,
            iconColor: freeHintsRemaining > 0 ? Colors.amber : Colors.amber.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required Color color,
    required Color textColor,
    required Color iconColor,
  }) {
    final isDisabled = onPressed == null;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey.withOpacity(0.1)
              : color,
          foregroundColor: isDisabled
              ? Colors.grey
              : textColor,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDisabled
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          elevation: isPrimary ? 4 : 0,
          shadowColor: isPrimary
              ? AppTheme.primaryPurple.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDisabled ? Colors.grey : iconColor,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDisabled ? Colors.grey : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Additional Control Widgets

class FloatingActionControls extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;

  const FloatingActionControls({
    Key? key,
    required this.onUndo,
    required this.onRedo,
    this.canUndo = false,
    this.canRedo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Undo Button
        FloatingActionButton(
          heroTag: "undo",
          onPressed: canUndo ? onUndo : null,
          backgroundColor: canUndo
              ? AppTheme.primaryPurple.withOpacity(0.8)
              : Colors.grey.withOpacity(0.3),
          child: Icon(
            Icons.undo,
            color: canUndo ? Colors.white : Colors.grey[600],
          ),
        ),

        SizedBox(height: 8),

        // Redo Button
        FloatingActionButton(
          heroTag: "redo",
          onPressed: canRedo ? onRedo : null,
          backgroundColor: canRedo
              ? AppTheme.primaryPurple.withOpacity(0.8)
              : Colors.grey.withOpacity(0.3),
          child: Icon(
            Icons.redo,
            color: canRedo ? Colors.white : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class QuickActionBar extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onHint;
  final VoidCallback onPause;
  final VoidCallback onSettings;
  final bool isPaused;
  final bool isComplete;

  const QuickActionBar({
    Key? key,
    required this.onReset,
    required this.onHint,
    required this.onPause,
    required this.onSettings,
    this.isPaused = false,
    this.isComplete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickButton(
            icon: Icons.refresh,
            onPressed: onReset,
            tooltip: 'Reset Level',
          ),

          SizedBox(width: 8),

          _buildQuickButton(
            icon: Icons.lightbulb_outline,
            onPressed: isComplete ? null : onHint,
            tooltip: 'Get Hint',
            iconColor: Colors.amber,
          ),

          SizedBox(width: 8),

          _buildQuickButton(
            icon: isPaused ? Icons.play_arrow : Icons.pause,
            onPressed: onPause,
            tooltip: isPaused ? 'Resume' : 'Pause',
          ),

          SizedBox(width: 8),

          _buildQuickButton(
            icon: Icons.settings,
            onPressed: onSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed != null
              ? (iconColor ?? Colors.white70)
              : Colors.grey,
          size: 20,
        ),
        splashRadius: 20,
      ),
    );
  }
}

class MoveCounter extends StatefulWidget {
  final int moves;
  final int? bestScore;
  final int? targetMoves;

  const MoveCounter({
    Key? key,
    required this.moves,
    this.bestScore,
    this.targetMoves,
  }) : super(key: key);

  @override
  _MoveCounterState createState() => _MoveCounterState();
}

class _MoveCounterState extends State<MoveCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _previousMoves = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _previousMoves = widget.moves;
  }

  @override
  void didUpdateWidget(MoveCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moves != _previousMoves) {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
      _previousMoves = widget.moves;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOptimal = widget.targetMoves != null &&
        widget.moves <= widget.targetMoves!;
    final isPersonalBest = widget.bestScore != null &&
        widget.moves < widget.bestScore!;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isOptimal
                  ? AppTheme.accentGreen.withOpacity(0.2)
                  : isPersonalBest
                  ? AppTheme.primaryPurple.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOptimal
                    ? AppTheme.accentGreen.withOpacity(0.5)
                    : isPersonalBest
                    ? AppTheme.primaryPurple.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: isOptimal ? AppTheme.accentGreen : Colors.white70,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  '${widget.moves}',
                  style: TextStyle(
                    color: isOptimal ? AppTheme.accentGreen : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.targetMoves != null) ...[
                  Text(
                    '/${widget.targetMoves}',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (isOptimal) ...[
                  SizedBox(width: 4),
                  Icon(
                    Icons.star,
                    color: AppTheme.accentGreen,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}