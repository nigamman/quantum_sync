// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../services/game_data_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onDataDeleted;

  const SettingsScreen({Key? key, this.onDataDeleted}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await GameDataService.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      // If there's an error loading settings, use defaults
      setState(() {
        _settings = {
          'soundEnabled': true,
          'hapticFeedback': true,
          'showHints': true,
          'colorBlindMode': false,
        };
        _isLoading = false;
      });
      print('Error loading settings: $e');
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    print('Updating setting: $key = $value');
    print('Current haptic setting: ${_settings['hapticFeedback']}');

    // Check haptic feedback setting properly
    if (_settings['hapticFeedback'] == true) {
      print('Triggering haptic for setting update...');
      HapticFeedback.lightImpact();
    } else {
      print('Haptic disabled, not triggering');
    }

    try {
      await GameDataService.saveSetting(key, value);
      setState(() {
        _settings[key] = value;
      });
      print('Setting saved successfully: $key = $value');

      // Show a brief confirmation
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Setting updated successfully!'),
          backgroundColor: AppTheme.accentGreen,
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error saving setting: $e');
      // Show error message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update setting. Please try again.'),
          backgroundColor: AppTheme.primaryPink,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    // Haptic feedback for important action
    if (_settings['hapticFeedback'] == true) {
      HapticFeedback.heavyImpact();
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Make sure user makes a conscious choice
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.primaryPink, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete All Data?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            _buildDeleteItem('• All game progress'),
            _buildDeleteItem('• High scores and achievements'),
            _buildDeleteItem('• Game statistics'),
            _buildDeleteItem('• All settings preferences'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.primaryPink, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('CANCEL', style: TextStyle(color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'DELETE ALL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Future<void> _deleteAllData() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryPurple,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accentGreen),
            SizedBox(height: 16),
            Text(
              'Deleting all data...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      await GameDataService.resetAllData();

      // Close loading dialog
      Navigator.pop(context);

      // Reset local settings to defaults
      setState(() {
        _settings = {
          'soundEnabled': true,
          'hapticFeedback': true,
          'showHints': true,
          'colorBlindMode': false,
        };
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('All data has been deleted successfully!'),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Notify parent that data was deleted
      widget.onDataDeleted?.call();

      // Wait a moment then navigate back
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      print('Error deleting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to delete data. Please try again.'),
            ],
          ),
          backgroundColor: AppTheme.primaryPink,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAboutDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_settings['hapticFeedback'] == true) {
                          HapticFeedback.lightImpact();
                        }
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Content
              Expanded(
                child: _isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Loading settings...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game Settings Section
                      _buildSectionTitle('Game Settings'),
                      _buildSettingTile(
                        'Sound Effects',
                        'Enable sound effects during gameplay',
                        Icons.volume_up,
                        _settings['soundEnabled'] ?? true,
                            (value) => _updateSetting('soundEnabled', value),
                      ),
                      _buildSettingTile(
                        'Haptic Feedback',
                        'Enable vibration feedback',
                        Icons.vibration,
                        _settings['hapticFeedback'] ?? true,
                            (value) => _updateSetting('hapticFeedback', value),
                      ),
                      _buildSettingTile(
                        'Show Hints',
                        'Display hint availability',
                        Icons.lightbulb,
                        _settings['showHints'] ?? true,
                            (value) => _updateSetting('showHints', value),
                      ),

                      SizedBox(height: 24),

                      // Accessibility Section
                      _buildSectionTitle('Accessibility'),
                      _buildSettingTile(
                        'Color Blind Mode',
                        'Adjust colors for better visibility',
                        Icons.accessibility,
                        _settings['colorBlindMode'] ?? false,
                            (value) => _updateSetting('colorBlindMode', value),
                      ),

                      SizedBox(height: 24),

                      // Data Management Section
                      _buildSectionTitle('Data Management'),
                      _buildActionTile(
                        'Delete All Data',
                        'Permanently delete all progress and scores',
                        Icons.delete_forever,
                        AppTheme.primaryPink,
                        _showDeleteConfirmation,
                      ),

                      SizedBox(height: 24),

                      // About Section
                      _buildSectionTitle('About'),
                      _buildInfoTile(
                        'About Us',
                        '',
                        Icons.info,
                        onTap: _showAboutDialog,
                      ),
                      _buildInfoTile(
                        'Version',
                        '1.0.0',
                        Icons.person,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.accentGreen,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: AppTheme.glassDecoration.copyWith(
        border: Border.all(
          color: value ? AppTheme.accentGreen.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: value ? AppTheme.accentGreen : AppTheme.primaryPurple,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white60),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accentGreen,
          activeTrackColor: AppTheme.accentGreen.withOpacity(0.3),
          inactiveThumbColor: Colors.white60,
          inactiveTrackColor: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildActionTile(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: AppTheme.glassDecoration,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white60)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
        onTap: () {
          if (_settings['hapticFeedback'] == true) {
            HapticFeedback.lightImpact();
          }
          onTap();
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: AppTheme.glassDecoration,
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: TextStyle(color: Colors.white)),
        trailing: onTap != null
            ? Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16)
            : Text(value, style: TextStyle(color: Colors.white60)),
        onTap: onTap != null ? () {
          if (_settings['hapticFeedback'] == true) {
            HapticFeedback.lightImpact();
          }
          onTap();
        } : null,
      ),
    );
  }

  void _triggerHapticWithDebug() {
    print('Haptic settings: ${_settings['hapticFeedback']}');
    print('All settings: $_settings');

    if (_settings['hapticFeedback'] == true) {
      print('Triggering haptic feedback...');
      HapticFeedback.lightImpact();
    } else {
      print('Haptic feedback is disabled');
    }
  }
}