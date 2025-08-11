// lib/widgets/stats_card.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatsCard extends StatelessWidget {
  final int moves;
  final int? bestScore;
  final int level;

  const StatsCard({
    Key? key,
    required this.moves,
    required this.bestScore,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('MOVES', moves.toString(), Colors.white, Icons.touch_app),
          _buildStat('BEST', bestScore?.toString() ?? '—', Colors.green, Icons.star),
          _buildStat('RANK', _getRankStars(level), Colors.amber, Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
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

  String _getRankStars(int level) {
    if (level <= 5) return '★';
    if (level <= 15) return '★★';
    if (level <= 30) return '★★★';
    if (level <= 50) return '★★★★';
    return '★★★★★';
  }
}