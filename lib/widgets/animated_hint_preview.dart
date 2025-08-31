// lib/widgets/animated_hint_preview.dart
import 'package:flutter/material.dart';
import '../services/hint_service.dart';
import '../services/game_logic_service.dart';
import '../utils/app_theme.dart';

class AnimatedHintPreview extends StatefulWidget {
  final List<List<int>> currentGrid;
  final Move move;

  const AnimatedHintPreview({
    Key? key,
    required this.currentGrid,
    required this.move,
  }) : super(key: key);

  @override
  _AnimatedHintPreviewState createState() => _AnimatedHintPreviewState();
}

class _AnimatedHintPreviewState extends State<AnimatedHintPreview>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _highlightController;
  late AnimationController _arrowController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _highlightAnimation;
  late Animation<double> _arrowPulseAnimation;

  List<List<int>> _displayGrid = [];
  List<List<int>> _resultGrid = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeGrids();
    _startAnimation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _highlightController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _arrowController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 0.8, curve: Curves.easeInOutCubic),
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _highlightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));

    _arrowPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 1000), () {
          if (mounted) {
            _resetAnimation();
          }
        });
      }
    });
  }

  void _initializeGrids() {
    _displayGrid = widget.currentGrid.map((row) => List<int>.from(row)).toList();
    _resultGrid = widget.currentGrid.map((row) => List<int>.from(row)).toList();

    // Apply the move to result grid to show the end state
    _applyMove(_resultGrid, widget.move);
  }

  void _applyMove(List<List<int>> grid, Move move) {
    switch (move.type) {
      case MoveType.rowLeft:
        GameLogicService.rotateRow(grid, move.index, -1);
        break;
      case MoveType.rowRight:
        GameLogicService.rotateRow(grid, move.index, 1);
        break;
      case MoveType.columnUp:
        GameLogicService.rotateColumn(grid, move.index, -1);
        break;
      case MoveType.columnDown:
        GameLogicService.rotateColumn(grid, move.index, 1);
        break;
    }
  }

  void _startAnimation() {
    _highlightController.repeat(reverse: true);
    _arrowController.repeat(reverse: true);

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isAnimating = true;
        });
        _animationController.forward();
      }
    });
  }

  void _resetAnimation() {
    _animationController.reset();
    setState(() {
      _displayGrid = widget.currentGrid.map((row) => List<int>.from(row)).toList();
      _isAnimating = false;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _startAnimation();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _highlightController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getMoveColor().withOpacity(0.15),
            _getMoveColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getMoveColor().withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getMoveColor().withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMoveColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  color: _getMoveColor(),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Watch the Move',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Animated demonstration
          _buildAnimatedDemo(),

          SizedBox(height: 16),

          // Move description
          _buildMoveDescription(),
        ],
      ),
    );
  }

  Widget _buildAnimatedDemo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Arrow indicators
          if (_isRowMove()) _buildHorizontalArrows(),
          if (_isColumnMove()) _buildTopArrow(),

          // Main grid with side arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left arrow for row moves
              if (_isRowMove())
                _buildSideArrow(Icons.keyboard_arrow_left, isLeft: true),

              if (_isColumnMove())
                SizedBox(width: 40), // Space for alignment

              // Grid
              _buildAnimatedGrid(),

              // Right arrow for row moves
              if (_isRowMove())
                _buildSideArrow(Icons.keyboard_arrow_right, isLeft: false),

              if (_isColumnMove())
                SizedBox(width: 40), // Space for alignment
            ],
          ),

          // Bottom arrow for column moves
          if (_isColumnMove()) _buildBottomArrow(),
        ],
      ),
    );
  }

  Widget _buildAnimatedGrid() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Interpolate between current and result grid
        final interpolatedGrid = _interpolateGrids();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: interpolatedGrid.asMap().entries.map((rowEntry) {
            final rowIndex = rowEntry.key;
            final row = rowEntry.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: row.asMap().entries.map((cellEntry) {
                final colIndex = cellEntry.key;
                final cellValue = cellEntry.value;

                return _buildAnimatedCell(
                  rowIndex,
                  colIndex,
                  cellValue,
                  _shouldHighlightCell(rowIndex, colIndex),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  List<List<int>> _interpolateGrids() {
    if (!_isAnimating) return _displayGrid;

    final progress = _slideAnimation.value;
    if (progress < 0.5) {
      return _displayGrid;
    } else {
      return _resultGrid;
    }
  }

  Widget _buildAnimatedCell(int row, int col, int value, bool shouldHighlight) {
    return AnimatedBuilder(
      animation: Listenable.merge([_highlightController, _animationController]),
      builder: (context, child) {
        final scale = shouldHighlight
            ? 1.0 + (_highlightAnimation.value * 0.15)
            : 1.0;

        final glowIntensity = shouldHighlight
            ? _highlightAnimation.value * 0.6
            : 0.0;

        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 35,
            height: 35,
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getCellColor(value),
              borderRadius: BorderRadius.circular(6),
              border: shouldHighlight
                  ? Border.all(
                color: _getMoveColor().withOpacity(0.8),
                width: 2,
              )
                  : Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: _getCellColor(value).withOpacity(0.4),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
                if (shouldHighlight)
                  BoxShadow(
                    color: _getMoveColor().withOpacity(glowIntensity),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalArrows() {
    final targetRow = widget.move.index;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isTarget = index == targetRow;
        return AnimatedBuilder(
          animation: _arrowController,
          builder: (context, child) {
            final scale = isTarget
                ? _arrowPulseAnimation.value
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 35,
                height: 20,
                margin: EdgeInsets.all(2),
                child: isTarget
                    ? Icon(
                  widget.move.type == MoveType.rowLeft
                      ? Icons.keyboard_arrow_left
                      : Icons.keyboard_arrow_right,
                  color: _getMoveColor(),
                  size: 16,
                )
                    : null,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTopArrow() {
    final targetCol = widget.move.index;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 40), // Left space
        ...List.generate(3, (index) {
          final isTarget = index == targetCol;
          return AnimatedBuilder(
            animation: _arrowController,
            builder: (context, child) {
              final scale = isTarget
                  ? _arrowPulseAnimation.value
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 35,
                  height: 20,
                  margin: EdgeInsets.all(2),
                  child: isTarget && widget.move.type == MoveType.columnUp
                      ? Icon(
                    Icons.keyboard_arrow_up,
                    color: _getMoveColor(),
                    size: 16,
                  )
                      : null,
                ),
              );
            },
          );
        }),
        SizedBox(width: 40), // Right space
      ],
    );
  }

  Widget _buildBottomArrow() {
    final targetCol = widget.move.index;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 40), // Left space
        ...List.generate(3, (index) {
          final isTarget = index == targetCol;
          return AnimatedBuilder(
            animation: _arrowController,
            builder: (context, child) {
              final scale = isTarget
                  ? _arrowPulseAnimation.value
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 35,
                  height: 20,
                  margin: EdgeInsets.all(2),
                  child: isTarget && widget.move.type == MoveType.columnDown
                      ? Icon(
                    Icons.keyboard_arrow_down,
                    color: _getMoveColor(),
                    size: 16,
                  )
                      : null,
                ),
              );
            },
          );
        }),
        SizedBox(width: 40), // Right space
      ],
    );
  }

  Widget _buildSideArrow(IconData icon, {required bool isLeft}) {
    final targetRow = widget.move.index;
    return Column(
      children: List.generate(3, (index) {
        final isTarget = index == targetRow;
        final shouldShow = isTarget &&
            ((isLeft && widget.move.type == MoveType.rowLeft) ||
                (!isLeft && widget.move.type == MoveType.rowRight));

        return AnimatedBuilder(
          animation: _arrowController,
          builder: (context, child) {
            final scale = shouldShow
                ? _arrowPulseAnimation.value
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 30,
                height: 35,
                margin: EdgeInsets.all(2),
                child: shouldShow
                    ? Icon(
                  icon,
                  color: _getMoveColor(),
                  size: 16,
                )
                    : null,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMoveDescription() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: _getMoveColor(),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _getMoveDescription(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isRowMove() {
    return widget.move.type == MoveType.rowLeft ||
        widget.move.type == MoveType.rowRight;
  }

  bool _isColumnMove() {
    return widget.move.type == MoveType.columnUp ||
        widget.move.type == MoveType.columnDown;
  }

  bool _shouldHighlightCell(int row, int col) {
    if (_isRowMove()) {
      return row == widget.move.index;
    } else {
      return col == widget.move.index;
    }
  }

  Color _getMoveColor() {
    switch (widget.move.type) {
      case MoveType.rowLeft:
        return Colors.blue;
      case MoveType.rowRight:
        return Colors.green;
      case MoveType.columnUp:
        return Colors.orange;
      case MoveType.columnDown:
        return Colors.purple;
    }
  }

  String _getMoveDescription() {
    final rowCol = _isRowMove()
        ? 'Row ${widget.move.index + 1}'
        : 'Column ${widget.move.index + 1}';

    final direction = widget.move.type.toString().split('.').last;

    return 'Rotate $rowCol ${direction.toUpperCase()} - Watch how colors transform!';
  }

  Color _getCellColor(int value) {
    switch (value % 4) {
      case 0: return Color(0xFF1E293B); // Dark slate
      case 1: return Color(0xFF3B82F6); // Blue
      case 2: return Color(0xFF8B5CF6); // Purple
      case 3: return Color(0xFF10B981); // Green
      default: return Colors.grey;
    }
  }
}