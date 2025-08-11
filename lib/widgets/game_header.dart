import 'package:flutter/material.dart';
import '../services/game_logic_service.dart';

class GameHeader extends StatelessWidget {
  final int level;
  final VoidCallback onBackPressed;
  final VoidCallback onHelpPressed;

  const GameHeader({
    Key? key,
    required this.level,
    required this.onBackPressed,
    required this.onHelpPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBackPressed,
          icon: Icon(Icons.home, color: Colors.white),
        ),
        Column(
          children: [
            Text(
              'Level $level/100',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              GameLogicService.getDifficultyLabel(level),
              style: TextStyle(
                color: Colors.purple[300],
                fontSize: 12,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: onHelpPressed,
          icon: Icon(Icons.help_outline, color: Colors.white),
        ),
      ],
    );
  }
}