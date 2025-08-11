import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class WarningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Take full width
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First line with icon and text
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.yellow,
                  size: 20,
                ),
                SizedBox(width: 6),
                Text(
                  'WARNING: Level 1 is already brutally',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: MediaQuery.of(context).size.width < 360 ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Remaining lines
            Text(
              'difficult.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: MediaQuery.of(context).size.width < 360 ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Only 0.1% reach Level 100.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: MediaQuery.of(context).size.width < 360 ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}