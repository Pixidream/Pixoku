import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class AnimatedPopup extends StatefulWidget {
  final Widget child;
  final bool showPopup;
  final VoidCallback? onDismissed;
  final PopupAnimationType animationType;
  final Duration animationDuration;
  final Color? barrierColor;
  final bool barrierDismissible;
  final bool enableFeedback;
  final Alignment alignment;

  const AnimatedPopup({
    super.key,
    required this.child,
    required this.showPopup,
    this.onDismissed,
    this.animationType = PopupAnimationType.scale,
    this.animationDuration = const Duration(milliseconds: 300),
    this.barrierColor,
    this.barrierDismissible = true,
    this.enableFeedback = true,
    this.alignment = Alignment.center,
  });

  @override
  State<AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<AnimatedPopup>
    with TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  final FeedbackService _feedbackService = FeedbackService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: _getSlideBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  Offset _getSlideBeginOffset() {
    switch (widget.animationType) {
      case PopupAnimationType.slideFromTop:
        return const Offset(0.0, -1.0);
      case PopupAnimationType.slideFromBottom:
        return const Offset(0.0, 1.0);
      case PopupAnimationType.slideFromLeft:
        return const Offset(-1.0, 0.0);
      case PopupAnimationType.slideFromRight:
        return const Offset(1.0, 0.0);
      default:
        return const Offset(0.0, 1.0);
    }
  }

  @override
  void didUpdateWidget(AnimatedPopup oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showPopup != oldWidget.showPopup) {
      if (widget.showPopup) {
        _showPopup();
      } else {
        _hidePopup();
      }
    }
  }

  void _showPopup() {
    if (widget.enableFeedback) {
      _feedbackService.playFeedback(FeedbackType.success);
    }
    _controller.forward();
  }

  void _hidePopup() {
    _controller.reverse().then((_) {
      if (widget.onDismissed != null) {
        widget.onDismissed!();
      }
    });
  }

  void _handleBarrierTap() {
    if (widget.barrierDismissible) {
      if (widget.enableFeedback) {
        _feedbackService.playFeedback(FeedbackType.buttonTap);
      }
      _hidePopup();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedChild() {
    Widget animatedChild = widget.child;

    switch (widget.animationType) {
      case PopupAnimationType.scale:
        animatedChild = AnimatedBuilder(
          animation: _scaleAnimation,
          child: animatedChild,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
        );
        break;

      case PopupAnimationType.fade:
        animatedChild = AnimatedBuilder(
          animation: _fadeAnimation,
          child: animatedChild,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            );
          },
        );
        break;

      case PopupAnimationType.slideFromTop:
      case PopupAnimationType.slideFromBottom:
      case PopupAnimationType.slideFromLeft:
      case PopupAnimationType.slideFromRight:
        animatedChild = AnimatedBuilder(
          animation: _slideAnimation,
          child: animatedChild,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: child,
            );
          },
        );
        break;

      case PopupAnimationType.bounceScale:
        animatedChild = AnimatedBuilder(
          animation: _scaleAnimation,
          child: animatedChild,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
        );
        break;

      case PopupAnimationType.rotateScale:
        animatedChild = AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
          child: animatedChild,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.1,
                child: child,
              ),
            );
          },
        );
        break;

      case PopupAnimationType.custom:
        // For custom animations, just use scale as default
        animatedChild = AnimatedBuilder(
          animation: _scaleAnimation,
          child: animatedChild,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
        );
        break;
    }

    // Always apply fade for the overall popup
    return FadeTransition(
      opacity: _fadeAnimation,
      child: animatedChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showPopup && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Barrier
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTap: _handleBarrierTap,
                child: Container(
                  color: (widget.barrierColor ?? Colors.black54)
                      .withValues(alpha: _fadeAnimation.value * 0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),

          // Popup content
          Align(
            alignment: widget.alignment,
            child: _buildAnimatedChild(),
          ),
        ],
      ),
    );
  }
}

// Enum for popup animation types
enum PopupAnimationType {
  scale,
  fade,
  slideFromTop,
  slideFromBottom,
  slideFromLeft,
  slideFromRight,
  bounceScale,
  rotateScale,
  custom,
}

// Pre-built popup widgets for common use cases
class SudokuPopup {

  // Confirmation dialog
  static Widget confirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    PopupAnimationType animationType = PopupAnimationType.scale,
  }) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Victory dialog
  static Widget victory({
    required String timeText,
    required String scoreText,
    required VoidCallback onMenu,
    required VoidCallback onNewGame,
    PopupAnimationType animationType = PopupAnimationType.bounceScale,
  }) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Victory icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Félicitations!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Vous avez résolu le Sudoku!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Temps:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Score:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      scoreText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onMenu,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNewGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Nouveau jeu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Loading popup
  static Widget loading({
    String message = 'Chargement...',
    PopupAnimationType animationType = PopupAnimationType.fade,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Custom popup container
  static Widget custom({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(24),
    double borderRadius = 16,
    Color backgroundColor = Colors.white,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Helper class for showing animated popups
class PopupManager {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    PopupAnimationType animationType = PopupAnimationType.scale,
    Duration animationDuration = const Duration(milliseconds: 300),
    bool barrierDismissible = true,
    Color? barrierColor,
    bool enableFeedback = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => AnimatedPopup(
        showPopup: true,
        animationType: animationType,
        animationDuration: animationDuration,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        enableFeedback: enableFeedback,
        child: child,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
