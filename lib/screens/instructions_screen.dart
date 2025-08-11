// lib/screens/instructions_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/demo_grid.dart';
import '../widgets/instruction_text.dart';
import '../widgets/step_indicator.dart';

class InstructionsScreen extends StatefulWidget {
  @override
  _InstructionsScreenState createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _demoController;
  late AnimationController _arrowController;

  int currentStep = 0;

  List<List<int>> demoGrid = [
    [0, 1, 2],
    [2, 0, 1],
    [1, 2, 0],
  ];

  List<List<int>> targetGrid = [
    [0, 0, 0],
    [1, 1, 1],
    [2, 2, 2],
  ];

  final List<InstructionStep> instructions = [
    InstructionStep(
      title: "Welcome to Quantum Sync!",
      description: "Match the target pattern by rotating rows and columns. But here's the twist - colors change when you move them!",
      highlightType: HighlightType.none,
    ),
    InstructionStep(
      title: "Tap Arrows to Rotate",
      description: "Use the arrows around the grid to rotate entire rows left/right or columns up/down.",
      highlightType: HighlightType.arrows,
    ),
    InstructionStep(
      title: "Colors Transform!",
      description: "Watch closely! When you rotate, squares don't just move - they change colors too! This is what makes it incredibly challenging.",
      highlightType: HighlightType.firstRow,
      demoAction: DemoAction.rotateFirstRow,
    ),
    InstructionStep(
      title: "Think Strategically",
      description: "Each move affects the entire pattern. You must think 3-4 moves ahead and understand how colors transform.",
      highlightType: HighlightType.grid,
    ),
    InstructionStep(
      title: "Master the Impossible",
      description: "100 levels await. Each one uses complex mathematical patterns. Only the most dedicated minds reach Level 100!",
      highlightType: HighlightType.target,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInstructionLoop();
  }

  void _setupAnimations() {
    _demoController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _arrowController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startInstructionLoop() {
    // Manual navigation only - no automatic progression
    _arrowController.repeat(reverse: true);
  }

  void _nextStep() {
    if (currentStep < instructions.length - 1) {
      setState(() {
        currentStep++;
        
        // Execute demo action if specified
        final instruction = instructions[currentStep];
        if (instruction.demoAction == DemoAction.rotateFirstRow) {
          _executeDemoAnimation();
        }
      });
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        
        // Execute demo action if specified
        final instruction = instructions[currentStep];
        if (instruction.demoAction == DemoAction.rotateFirstRow) {
          _executeDemoAnimation();
        }
      });
    }
  }

  void _executeDemoAnimation() {
    _demoController.forward().then((_) {
      setState(() {
        // Rotate first row and change colors
        final temp = demoGrid[0][0];
        demoGrid[0][0] = (demoGrid[0][1] + 1) % 4; // Color change!
        demoGrid[0][1] = (demoGrid[0][2] + 1) % 4; // Color change!
        demoGrid[0][2] = (temp + 1) % 4; // Color change!
      });
      _demoController.reverse();
    });
  }



  @override
  void dispose() {
    _demoController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How to Play'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Instruction Text
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        InstructionText(
                          instruction: instructions[currentStep],
                          animationKey: ValueKey(currentStep),
                        ),

                        SizedBox(height: 24),

                        // Target Pattern
                        _buildSectionTitle('TARGET PATTERN'),
                        SizedBox(height: 8),
                        DemoGrid(
                          grid: targetGrid,
                          isTarget: true,
                          highlightType: instructions[currentStep].highlightType == HighlightType.target
                              ? HighlightType.target
                              : HighlightType.none,
                        ),

                        SizedBox(height: 24),

                        // Demo Section
                        _buildSectionTitle('YOUR GRID'),
                        SizedBox(height: 8),

                        _buildDemoSection(),
                      ],
                    ),
                  ),
                ),

                // Navigation Controls
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button
                      IconButton(
                        onPressed: currentStep > 0 ? _previousStep : null,
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: currentStep > 0 
                              ? AppTheme.primaryPurple.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          shape: CircleBorder(),
                        ),
                      ),

                      // Step Indicator
                      Expanded(
                        child: StepIndicator(
                          currentStep: currentStep,
                          totalSteps: instructions.length,
                        ),
                      ),

                      // Next Button
                      IconButton(
                        onPressed: currentStep < instructions.length - 1 ? _nextStep : null,
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: currentStep < instructions.length - 1
                              ? AppTheme.primaryPurple.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                        label: Text('BACK TO MENU'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.5)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/game');
                        },
                        icon: Icon(Icons.play_arrow),
                        label: Text('START GAME'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDemoSection() {
    return Column(
      children: [
        // Top arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 50), // Space for left arrows
            for (int i = 0; i < 3; i++) ...[
              _buildArrowButton(
                icon: Icons.keyboard_arrow_up,
                isHighlighted: _shouldHighlightArrow(ArrowType.columnUp, i),
                onTap: () {},
              ),
            ],
            SizedBox(width: 50), // Space for right arrows
          ],
        ),

        // Main section with side arrows and grid
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left arrows
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  _buildArrowButton(
                    icon: Icons.keyboard_arrow_left,
                    isHighlighted: _shouldHighlightArrow(ArrowType.rowLeft, i),
                    onTap: () {},
                    isVertical: true,
                  ),
              ],
            ),

            SizedBox(width: 12),

            // Demo Grid
            DemoGrid(
              grid: demoGrid,
              isTarget: false,
              animationController: _demoController,
              highlightType: instructions[currentStep].highlightType,
              highlightRowIndex: 0,
            ),

            SizedBox(width: 12),

            // Right arrows
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  _buildArrowButton(
                    icon: Icons.keyboard_arrow_right,
                    isHighlighted: _shouldHighlightArrow(ArrowType.rowRight, i),
                    onTap: () {},
                    isVertical: true,
                  ),
              ],
            ),
          ],
        ),

        // Bottom arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 50), // Space for left arrows
            for (int i = 0; i < 3; i++) ...[
              _buildArrowButton(
                icon: Icons.keyboard_arrow_down,
                isHighlighted: _shouldHighlightArrow(ArrowType.columnDown, i),
                onTap: () {},
              ),
            ],
            SizedBox(width: 50), // Space for right arrows
          ],
        ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool isHighlighted,
    required VoidCallback onTap,
    bool isVertical = false,
  }) {
    return AnimatedBuilder(
      animation: _arrowController,
      builder: (context, child) {
        final scale = isHighlighted
            ? 1.0 + (_arrowController.value * 0.3)
            : 1.0;
        final opacity = isHighlighted
            ? 0.7 + (_arrowController.value * 0.3)
            : 0.4;

        return GestureDetector(
          onTap: onTap,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: isVertical ? 30 : 40,
              height: isVertical ? 40 : 30,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isHighlighted
                      ? AppTheme.primaryPurple
                      : Colors.white.withOpacity(0.2),
                  width: isHighlighted ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(opacity),
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _shouldHighlightArrow(ArrowType type, int index) {
    final currentInstruction = instructions[currentStep];

    if (currentInstruction.highlightType == HighlightType.arrows) {
      return true; // Highlight all arrows
    }

    if (currentInstruction.highlightType == HighlightType.firstRow &&
        currentInstruction.demoAction == DemoAction.rotateFirstRow) {
      return (type == ArrowType.rowLeft || type == ArrowType.rowRight) && index == 0;
    }

    return false;
  }
}

// Supporting classes
class InstructionStep {
  final String title;
  final String description;
  final HighlightType highlightType;
  final DemoAction? demoAction;

  InstructionStep({
    required this.title,
    required this.description,
    required this.highlightType,
    this.demoAction,
  });
}

enum HighlightType { none, arrows, firstRow, grid, target }
enum DemoAction { rotateFirstRow }
enum ArrowType { columnUp, columnDown, rowLeft, rowRight }