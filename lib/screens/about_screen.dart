// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_logo.dart';
import '../widgets/stat_card.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController = ScrollController();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Quantum Sync'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeader(),
                      
                      SizedBox(height: 32),
                      
                      // The Challenge Section
                      _buildChallengeSection(),
                      
                      SizedBox(height: 32),
                      
                      // The Secret Section
                      _buildSecretSection(),
                      
                      SizedBox(height: 32),
                      
                      // Statistics Section
                      _buildStatisticsSection(),
                      
                      SizedBox(height: 32),
                      
                      // The Journey Section
                      _buildJourneySection(),
                      
                      SizedBox(height: 32),
                      
                      // Developer Section
                      _buildDeveloperSection(),
                      
                      SizedBox(height: 32),
                      
                      // Warning Section
                      _buildWarningSection(),
                      
                      SizedBox(height: 40),
                      
                      // Call to Action
                      _buildCallToAction(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          AnimatedLogo(size: 80),
          SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.buttonGradient.createShader(bounds),
            child: Text(
              'QUANTUM SYNC',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.warningRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.warningRed.withOpacity(0.5)),
            ),
            child: Text(
              'Only 0.1% Reach Level 100',
              style: TextStyle(
                color: AppTheme.warningRed,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeSection() {
    return _buildSection(
      title: '🧠 The Ultimate Logic Challenge',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantum Sync isn\'t just another puzzle game. It\'s a brutal test of human intelligence that will push your brain to its absolute limits.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'What starts as a simple concept - "match the colored pattern by rotating rows and columns" - quickly evolves into mathematical warfare that has left PhD mathematicians scratching their heads.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretSection() {
    return _buildSection(
      title: '⚛️ The Secret That Breaks Minds',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Here\'s what makes Quantum Sync impossible:',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _buildBulletPoint('Colors don\'t just move - they TRANSFORM'),
                _buildBulletPoint('Each rotation applies quantum mechanical principles'),
                _buildBulletPoint('Mathematical patterns hidden in chaos theory'),
                _buildBulletPoint('Every move affects the entire dimensional matrix'),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'While other puzzle games move pieces around, Quantum Sync fundamentally alters reality. That blue square might become red, that red might become purple - following complex mathematical equations that most players never discover.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return _buildSection(
      title: '📊 The Brutal Statistics',
      content: Column(
        children: [
          Text(
            'These numbers don\'t lie. Quantum Sync has broken more minds than any puzzle game in history:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Level 1',
                  value: '40%',
                  subtitle: 'Completion Rate',
                  color: Colors.blue,
                  icon: Icons.looks_one,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Level 10',
                  value: '8%',
                  subtitle: 'Survival Rate',
                  color: AppTheme.primaryPurple,
                  icon: Icons.psychology,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Level 50',
                  value: '0.3%',
                  subtitle: 'Elite Territory',
                  color: Colors.orange,
                  icon: Icons.flash_on,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Level 100',
                  value: '0.1%',
                  subtitle: 'Quantum Gods',
                  color: Colors.amber,
                  icon: Icons.emoji_events,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.red, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Level 1 Completion Time',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '47 minutes, 23 seconds',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneySection() {
    return _buildSection(
      title: '🚀 Your Quantum Journey',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJourneyPhase(
            'Levels 1-10: Quantum Initiation',
            'Learn the basics. Realize this isn\'t like other games.',
            Colors.blue,
            '95% of players quit here',
          ),
          SizedBox(height: 16),
          _buildJourneyPhase(
            'Levels 11-25: Reality Bending',
            'Mathematics becomes your language. Patterns emerge.',
            AppTheme.primaryPurple,
            '85% of survivors quit here',
          ),
          SizedBox(height: 16),
          _buildJourneyPhase(
            'Levels 26-50: Mind Fracturing',
            'Fibonacci sequences. Prime numbers. Pure calculation.',
            Colors.orange,
            'Only the gifted continue',
          ),
          SizedBox(height: 16),
          _buildJourneyPhase(
            'Levels 51-75: Legendary Nightmare',
            'Quantum mechanics meet game design. Few understand.',
            Colors.red,
            'You are among the elite',
          ),
          SizedBox(height: 16),
          _buildJourneyPhase(
            'Levels 76-100: Quantum God Mode',
            'Transcend human limitations. Achieve digital enlightenment.',
            Colors.amber,
            'Reserved for the 0.1%',
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return _buildSection(
      title: '👨‍💻 From the Developers',
      content: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.buttonGradient,
                  ),
                  child: Icon(Icons.code, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  'Development Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '"We didn\'t set out to create the world\'s most difficult mobile game. We just wanted to build something that respected players\' intelligence."',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '"What emerged was a mathematical monster that challenges the very limits of human pattern recognition. We\'re honestly not sure if Level 100 is humanly possible - but we\'re excited to find out."',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  'Made with mathematical precision',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.warningRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningRed.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningRed.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber,
            color: AppTheme.warningRed,
            size: 40,
          ),
          SizedBox(height: 16),
          Text(
            'PSYCHOLOGICAL WARNING',
            style: TextStyle(
              color: AppTheme.warningRed,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Quantum Sync may cause:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ...[
            'Existential questioning of your intelligence',
            'Compulsive pattern-seeking behavior',
            'Dreams featuring rotating colored squares',
            'Sudden understanding of quantum mechanics',
            'Irresistible urge to explain Fibonacci sequences',
          ].map((warning) => Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppTheme.warningRed)),
                Expanded(
                  child: Text(
                    warning,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: 16),
          Text(
            'Play responsibly. Your sanity is valuable.',
            style: TextStyle(
              color: AppTheme.warningRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(height: 12),
              Text(
                'Ready to Test Your Limits?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Join the 0.1% who dare to think differently.\nBecome a Quantum Master.',
                style: TextStyle(
                  color: Colors.white10,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/instructions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('LEARN HOW'),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/game', 
                  (route) => route.settings.name == '/menu',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('BEGIN JOURNEY'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Version 1.0.0 • Made for the mathematically brave',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryPurple,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyPhase(
    String title,
    String description,
    Color color,
    String difficulty,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  difficulty,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
