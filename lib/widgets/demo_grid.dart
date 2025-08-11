// lib/widgets/demo_grid.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../screens/instructions_screen.dart';

class DemoGrid extends StatelessWidget {
  final List<List<int>> grid;
  final bool isTarget;
  final AnimationController? animationController;
  final HighlightType highlightType;
  final int highlightRowIndex;

  const DemoGrid({
    Key? key,
    required this.grid,
    this.isTarget = false,
    this.animationController,
    this.highlightType = HighlightType.none,
    this.highlightRowIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isTarget
            ? AppTheme.accentGreen.withOpacity(0.1)
            : Colors.black.withOpacity(0.2),
        border: Border.all(
            color: isTarget
                ? AppTheme.accentGreen.withOpacity(0.3)
                : Colors.white.withOpacity(0.2)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: grid.asMap().entries.map((rowEntry) =>
            Row(
              mainAxisSize: MainAxisSize.min,
              children: rowEntry.value.asMap().entries.map((cellEntry) =>
                  _buildCell(
                    rowEntry.key,
                    cellEntry.key,
                    cellEntry.value,
                  ),
              ).toList(),
            ),
        ).toList(),
      ),
    );
  }

  Widget _buildCell(int row, int col, int value) {
    final shouldHighlight = _shouldHighlightCell(row, col);

    return AnimatedBuilder(
      animation: animationController ?? AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final scale = shouldHighlight
            ? 1.0 + (animationController?.value ?? 0.0) * 0.2
            : 1.0;
        final glowIntensity = shouldHighlight
            ? (animationController?.value ?? 0.0) * 0.5
            : 0.0;

        return AnimatedContainer(
          duration: Duration(milliseconds: 500),
          transform: Matrix4.identity()..scale(scale),
          width: 40,
          height: 40,
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getCellColor(value),
            borderRadius: BorderRadius.circular(8),
            border: shouldHighlight
                ? Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.8),
              width: 2,
            )
                : Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: _getCellColor(value).withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
              if (shouldHighlight)
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(glowIntensity),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: shouldHighlight && highlightType == HighlightType.firstRow
              ? Icon(
            Icons.refresh,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          )
              : null,
        );
      },
    );
  }

  bool _shouldHighlightCell(int row, int col) {
    switch (highlightType) {
      case HighlightType.firstRow:
        return row == highlightRowIndex;
      case HighlightType.grid:
        return true;
      case HighlightType.target:
        return isTarget;
      default:
        return false;
    }
  }

  Color _getCellColor(int value) {
    switch (value % 4) {
      case 0: return Color(0xFF1E293B);
      case 1: return Color(0xFF3B82F6);
      case 2: return Color(0xFF8B5CF6);
      case 3: return Color(0xFF10B981);
      default: return Colors.grey;
    }
  }
}
