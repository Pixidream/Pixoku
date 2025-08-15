import 'package:flutter/material.dart';
import '../services/animation_service.dart';
import '../services/feedback_service.dart';
import '../utils/constants.dart';

class AnimatedSudokuCell extends StatefulWidget {
  final int? value;
  final List<int> notes;
  final bool isFixed;
  final bool isSelected;
  final bool isInSameRegion;
  final bool hasError;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool enableAnimations;

  const AnimatedSudokuCell({
    super.key,
    this.value,
    this.notes = const [],
    this.isFixed = false,
    this.isSelected = false,
    this.isInSameRegion = false,
    this.hasError = false,
    this.isHighlighted = false,
    required this.onTap,
    this.enableAnimations = true,
  });

  @override
  State<AnimatedSudokuCell> createState() => AnimatedSudokuCellState();
}

class AnimatedSudokuCellState extends State<AnimatedSudokuCell>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _selectionController;
  late AnimationController _fillController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late AnimationController _pulseController;
  late AnimationController _highlightController;

  // Animations
  late Animation<double> _selectionAnimation;
  late Animation<double> _fillAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successRotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _highlightAnimation;

  // Services
  final FeedbackService _feedbackService = FeedbackService();

  // State tracking
  int? _previousValue;
  bool _previousSelected = false;
  bool _previousError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _previousValue = widget.value;
    _previousSelected = widget.isSelected;
    _previousError = widget.hasError;
  }

  void _initializeAnimations() {
    // Initialize controllers
    _selectionController = AnimationService.createDefaultController(this);
    _fillController = AnimationService.createDefaultController(this);
    _shakeController = AnimationService.createFastController(this);
    _successController = AnimationService.createSlowController(this);
    _pulseController = AnimationService.createCustomController(
      this,
      const Duration(milliseconds: 1000)
    );
    _highlightController = AnimationService.createDefaultController(this);

    // Initialize animations
    _selectionAnimation = AnimationService.createCellSelectionAnimation(_selectionController);
    _fillAnimation = AnimationService.createCellFillAnimation(_fillController);
    _shakeAnimation = AnimationService.createShakeAnimation(_shakeController);
    _successScaleAnimation = AnimationService.createSuccessScaleAnimation(_successController);
    _successRotationAnimation = AnimationService.createSuccessRotationAnimation(_successController);
    _pulseAnimation = AnimationService.createPulseAnimation(_pulseController);
    _highlightAnimation = AnimationService.createHighlightAnimation(_highlightController);

    // Setup pulse animation to repeat
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AnimatedSudokuCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enableAnimations) return;

    // Handle selection changes
    if (widget.isSelected != _previousSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
        _feedbackService.cellSelected();
      } else {
        _selectionController.reverse();
      }
      _previousSelected = widget.isSelected;
    }

    // Handle value changes
    if (widget.value != _previousValue) {
      if (widget.value != null && widget.value! > 0) {
        // Number was placed
        _fillController.forward().then((_) {
          _fillController.reverse();
        });
        _feedbackService.numberPlaced();
      } else if (_previousValue != null && _previousValue! > 0) {
        // Number was removed
        _feedbackService.numberRemoved();
      }
      _previousValue = widget.value;
    }

    // Handle error state changes
    if (widget.hasError != _previousError) {
      if (widget.hasError) {
        _shakeController.forward().then((_) {
          _shakeController.reset();
        });
        _feedbackService.errorOccurred();
      }
      _previousError = widget.hasError;
    }

    // Handle highlight changes
    if (widget.isHighlighted) {
      _highlightController.forward();
    } else {
      _highlightController.reverse();
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _fillController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _pulseController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  Color _getCellColor() {
    if (widget.hasError) {
      return AppColors.errorCellBackground;
    }
    if (widget.isSelected) {
      return AppColors.selectedCellBackground;
    }
    if (widget.isInSameRegion) {
      return AppColors.sameRegionBackground;
    }
    if (widget.isHighlighted) {
      return AppColors.highlightedCellBackground;
    }
    if (widget.isFixed) {
      return AppColors.fixedCellBackground;
    }
    return AppColors.emptyCellBackground;
  }

  Color _getTextColor() {
    if (widget.hasError) {
      return AppColors.errorText;
    }
    if (widget.isFixed) {
      return AppColors.fixedText;
    }
    return AppColors.userText;
  }

  void _handleTap() {
    _feedbackService.buttonTapped();
    widget.onTap();
  }

  Widget _buildCellContent() {
    if (widget.value != null && widget.value! > 0) {
      // Display main number
      return Center(
        child: Text(
          widget.value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: widget.isFixed ? FontWeight.bold : FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
      );
    } else if (widget.notes.isNotEmpty) {
      // Display notes
      return _buildNotesGrid();
    } else {
      // Empty cell
      return const SizedBox.expand();
    }
  }

  Widget _buildNotesGrid() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          final hasNote = widget.notes.contains(number);

          return Center(
            child: hasNote
                ? Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.notesText,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cell = GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.selectedCellBorder
                : Colors.transparent,
            width: widget.isSelected ? 2 : 0,
          ),
        ),
        child: _buildCellContent(),
      ),
    );

    if (!widget.enableAnimations) {
      return cell;
    }

    // Apply animations
    return AnimatedBuilder(
      animation: Listenable.merge([
        _selectionAnimation,
        _fillAnimation,
        _shakeAnimation,
        _successScaleAnimation,
        _successRotationAnimation,
        _pulseAnimation,
        _highlightAnimation,
      ]),
      child: cell,
      builder: (context, child) {
        Widget animatedChild = child!;

        // Apply shake animation for errors
        if (_shakeAnimation.value > 0) {
          animatedChild = AnimationService.createShakeWidget(
            child: animatedChild,
            animation: _shakeAnimation,
          );
        }

        // Apply selection scaling
        if (_selectionAnimation.value > 1.0) {
          animatedChild = Transform.scale(
            scale: _selectionAnimation.value,
            child: animatedChild,
          );
        }

        // Apply fill animation (bounce effect)
        if (_fillAnimation.value > 0) {
          final scale = 1.0 + (_fillAnimation.value * 0.2);
          animatedChild = Transform.scale(
            scale: scale,
            child: animatedChild,
          );
        }

        // Apply pulse animation for highlighted cells
        if (widget.isHighlighted && _pulseAnimation.value > 1.0) {
          animatedChild = Transform.scale(
            scale: _pulseAnimation.value,
            child: animatedChild,
          );
        }

        // Apply highlight opacity animation
        if (_highlightAnimation.value > 0) {
          animatedChild = Opacity(
            opacity: 0.7 + (0.3 * _highlightAnimation.value),
            child: animatedChild,
          );
        }

        // Apply success animation (scale + rotation)
        if (_successScaleAnimation.value > 1.0) {
          animatedChild = AnimationService.createSuccessRotationWidget(
            child: animatedChild,
            scaleAnimation: _successScaleAnimation,
            rotationAnimation: _successRotationAnimation,
          );
        }

        return animatedChild;
      },
    );
  }

  // Method to trigger success animation externally
  void playSuccessAnimation() {
    if (widget.enableAnimations) {
      _successController.forward().then((_) {
        _successController.reverse();
      });
      _feedbackService.successAction();
    }
  }

  // Method to trigger custom animations
  void playCustomAnimation(AnimationType type) {
    if (!widget.enableAnimations) return;

    switch (type) {
      case AnimationType.success:
        playSuccessAnimation();
        break;
      case AnimationType.error:
        _shakeController.forward().then((_) {
          _shakeController.reset();
        });
        _feedbackService.errorOccurred();
        break;
      case AnimationType.highlight:
        _highlightController.forward();
        break;
      case AnimationType.unhighlight:
        _highlightController.reverse();
        break;
    }
  }
}

// Enum for animation types
enum AnimationType {
  success,
  error,
  highlight,
  unhighlight,
}

// Extension to access animation methods
extension AnimatedSudokuCellExtension on GlobalKey<AnimatedSudokuCellState> {
  void playSuccessAnimation() {
    currentState?.playSuccessAnimation();
  }

  void playCustomAnimation(AnimationType type) {
    currentState?.playCustomAnimation(type);
  }
}
