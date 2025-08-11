// lib/widgets/game_grid.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GameGrid extends StatelessWidget {
  final List<List<int>> grid;
  final bool isTarget;
  final bool isComplete;
  final AnimationController? animationController;
  final AnimationController? buttonAnimationController;
  final Function(int, int)? onRotateRow;
  final Function(int, int)? onRotateColumn;

  const GameGrid({
    Key? key,
    required this.grid,
    this.isTarget = false,
    this.isComplete = false,
    this.animationController,
    this.buttonAnimationController,
    this.onRotateRow,
    this.onRotateColumn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (grid.isEmpty) return SizedBox();

    final size = grid.length;
    final isInteractive = !isTarget && onRotateRow != null && onRotateColumn != null;

    if (isInteractive) {
      return _buildInteractiveGrid(size);
    } else {
      return _buildStaticGrid(size);
    }
  }

  Widget _buildInteractiveGrid(int size) {
    return Column(
      children: [
        // Top arrows (column rotation up)
        _buildTopArrows(size),

        // Main section with side arrows and grid
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left arrows (row rotation left)
            _buildLeftArrows(size),

            SizedBox(width: 12),

            // Main grid
            _buildGridContainer(size),

            SizedBox(width: 12),

            // Right arrows (row rotation right)
            _buildRightArrows(size),
          ],
        ),

        // Bottom arrows (column rotation down)
        _buildBottomArrows(size),
      ],
    );
  }

  Widget _buildTopArrows(int size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 50), // Space for left arrows
        ...List.generate(size, (colIndex) =>
            _buildArrowButton(
              icon: Icons.keyboard_arrow_up,
              onTap: () => onRotateColumn?.call(colIndex, -1),
              isVertical: false,
            ),
        ),
        SizedBox(width: 50), // Space for right arrows
      ],
    );
  }

  Widget _buildBottomArrows(int size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 50),
        ...List.generate(size, (colIndex) =>
            _buildArrowButton(
              icon: Icons.keyboard_arrow_down,
              onTap: () => onRotateColumn?.call(colIndex, 1),
              isVertical: false,
            ),
        ),
        SizedBox(width: 50),
      ],
    );
  }

  Widget _buildLeftArrows(int size) {
    return Column(
      children: List.generate(size, (rowIndex) =>
          _buildArrowButton(
            icon: Icons.keyboard_arrow_left,
            onTap: () => onRotateRow?.call(rowIndex, -1),
            isVertical: true,
          ),
      ),
    );
  }

  Widget _buildRightArrows(int size) {
    return Column(
      children: List.generate(size, (rowIndex) =>
          _buildArrowButton(
            icon: Icons.keyboard_arrow_right,
            onTap: () => onRotateRow?.call(rowIndex, 1),
            isVertical: true,
          ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isVertical,
  }) {
    return AnimatedBuilder(
      animation: buttonAnimationController ?? AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final scale = 1.0 + (buttonAnimationController?.value ?? 0.0) * 0.1;

        return GestureDetector(
          onTap: onTap,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: isVertical ? 35 : 40,
              height: isVertical ? 40 : 35,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridContainer(int size) {
    return Container(
      decoration: BoxDecoration(
        color: isTarget
            ? AppTheme.accentGreen.withOpacity(0.1)
            : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTarget
              ? AppTheme.accentGreen.withOpacity(0.3)
              : Colors.white.withOpacity(0.15),
          width: isComplete ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isComplete
                ? AppTheme.accentGreen.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: isComplete ? 15 : 8,
            spreadRadius: isComplete ? 2 : 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: _buildGridCells(size),
    );
  }

  Widget _buildStaticGrid(int size) {
    return Container(
      decoration: BoxDecoration(
        color: isTarget
            ? AppTheme.accentGreen.withOpacity(0.1)
            : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isTarget
                ? AppTheme.accentGreen.withOpacity(0.3)
                : Colors.white.withOpacity(0.15)
        ),
      ),
      padding: EdgeInsets.all(12),
      child: _buildGridCells(size),
    );
  }

  Widget _buildGridCells(int size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: grid.asMap().entries.map((rowEntry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: rowEntry.value.asMap().entries.map((cellEntry) {
            return AnimatedBuilder(
              animation: animationController ?? AlwaysStoppedAnimation(0.0),
              builder: (context, child) {
                final pulseScale = 1.0 + (animationController?.value ?? 0.0) * 0.1;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  transform: Matrix4.identity()..scale(pulseScale),
                  width: _getCellSize(size),
                  height: _getCellSize(size),
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _getCellColor(cellEntry.value),
                    borderRadius: BorderRadius.circular(8),
                    border: isComplete && !isTarget
                        ? Border.all(color: AppTheme.accentGreen, width: 2)
                        : Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: _getCellColor(cellEntry.value).withOpacity(0.4),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                      if (isComplete && !isTarget)
                        BoxShadow(
                          color: AppTheme.accentGreen.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: isComplete && !isTarget
                      ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: _getCellSize(size) * 0.5,
                  )
                      : null,
                );
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  double _getCellSize(int gridSize) {
    // Adjust cell size based on grid dimensions
    switch (gridSize) {
      case 3: return 42.0;
      case 4: return 38.0;
      case 5: return 34.0;
      case 6: return 30.0;
      default: return 40.0;
    }
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