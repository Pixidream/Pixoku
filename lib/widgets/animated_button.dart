import 'package:flutter/material.dart';

import '../services/feedback_service.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final AnimationStyle animationStyle;
  final Duration animationDuration;
  final bool enableFeedback;
  final bool enableSound;
  final bool enableHaptic;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.animationStyle = AnimationStyle.scale,
    this.animationDuration = const Duration(milliseconds: 150),
    this.enableFeedback = true,
    this.enableSound = true,
    this.enableHaptic = true,
  });

  // Factory constructors for common button styles
  factory AnimatedButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    AnimationStyle animationStyle = AnimationStyle.scale,
    bool enableFeedback = true,
  }) {
    return AnimatedButton(
      key: key,
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey[300],
      disabledForegroundColor: Colors.grey[600],
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      animationStyle: animationStyle,
      enableFeedback: enableFeedback,
      child: child,
    );
  }

  factory AnimatedButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    AnimationStyle animationStyle = AnimationStyle.scale,
    bool enableFeedback = true,
  }) {
    return AnimatedButton(
      key: key,
      onPressed: onPressed,
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.grey[800],
      disabledBackgroundColor: Colors.grey[100],
      disabledForegroundColor: Colors.grey[400],
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[300]!),
      animationStyle: animationStyle,
      enableFeedback: enableFeedback,
      child: child,
    );
  }

  factory AnimatedButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required IconData icon,
    double? size,
    Color? color,
    Color? backgroundColor,
    AnimationStyle animationStyle = AnimationStyle.bounce,
    bool enableFeedback = true,
  }) {
    return AnimatedButton(
      key: key,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: color ?? Colors.grey[600],
      width: size ?? 48,
      height: size ?? 48,
      borderRadius: BorderRadius.circular((size ?? 48) / 2),
      animationStyle: animationStyle,
      enableFeedback: enableFeedback,
      child: Icon(icon, size: (size ?? 48) * 0.6),
    );
  }

  factory AnimatedButton.floating({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    AnimationStyle animationStyle = AnimationStyle.bounce,
    bool enableFeedback = true,
  }) {
    return AnimatedButton(
      key: key,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.blue,
      foregroundColor: Colors.white,
      width: 56,
      height: 56,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      animationStyle: animationStyle,
      enableFeedback: enableFeedback,
      child: child,
    );
  }

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  final FeedbackService _feedbackService = FeedbackService();

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Create different animations based on style
    switch (widget.animationStyle) {
      case AnimationStyle.scale:
        _scaleAnimation = Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));
        break;

      case AnimationStyle.bounce:
        _scaleAnimation = Tween<double>(
          begin: 1.0,
          end: 0.9,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.bounceOut,
        ));
        break;

      case AnimationStyle.fade:
        _opacityAnimation = Tween<double>(
          begin: 1.0,
          end: 0.7,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));
        break;

      case AnimationStyle.rotate:
        _rotationAnimation = Tween<double>(
          begin: 0.0,
          end: 0.1,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));
        break;

      case AnimationStyle.slide:
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.02, 0.02),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();

      if (widget.enableFeedback && widget.enableHaptic) {
        _feedbackService.playHaptic(FeedbackType.buttonTap);
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTap() {
    if (widget.onPressed != null) {
      if (widget.enableFeedback && widget.enableSound) {
        _feedbackService.playSound(FeedbackType.buttonTap);
      }
      widget.onPressed!();
    }
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null) {
      return widget.disabledBackgroundColor ?? Colors.grey[300]!;
    }
    return widget.backgroundColor ?? Colors.blue;
  }

  Color _getForegroundColor() {
    if (widget.onPressed == null) {
      return widget.disabledForegroundColor ?? Colors.grey[600]!;
    }
    return widget.foregroundColor ?? Colors.white;
  }

  Widget _buildAnimatedChild(Widget child) {
    switch (widget.animationStyle) {
      case AnimationStyle.scale:
      case AnimationStyle.bounce:
        return AnimatedBuilder(
          animation: _scaleAnimation,
          child: child,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
        );

      case AnimationStyle.fade:
        return AnimatedBuilder(
          animation: _opacityAnimation,
          child: child,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            );
          },
        );

      case AnimationStyle.rotate:
        return AnimatedBuilder(
          animation: _rotationAnimation,
          child: child,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            );
          },
        );

      case AnimationStyle.slide:
        return AnimatedBuilder(
          animation: _slideAnimation,
          child: child,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _slideAnimation.value.dx * 10,
                _slideAnimation.value.dy * 10,
              ),
              child: child,
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          border: widget.border,
          boxShadow: widget.onPressed == null
              ? null
              : (_isPressed
                  ? (widget.boxShadow?.map((shadow) => shadow.copyWith(
                      blurRadius: shadow.blurRadius * 0.5,
                      offset: shadow.offset * 0.5,
                    )).toList())
                  : widget.boxShadow),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: _getForegroundColor(),
            fontWeight: FontWeight.w600,
          ),
          child: IconTheme(
            data: IconThemeData(
              color: _getForegroundColor(),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );

    return _buildAnimatedChild(button);
  }
}

// Enum for different animation styles
enum AnimationStyle {
  scale,
  bounce,
  fade,
  rotate,
  slide,
}

// Custom button styles for the Sudoku app
class SudokuButton {
  static Widget number({
    required VoidCallback? onPressed,
    required String number,
    bool isDisabled = false,
  }) {
    return AnimatedButton(
      onPressed: isDisabled ? null : onPressed,
      backgroundColor: isDisabled ? Colors.grey[300] : Colors.blue[50],
      foregroundColor: isDisabled ? Colors.grey[500] : Colors.blue[700],
      disabledBackgroundColor: Colors.grey[200],
      disabledForegroundColor: Colors.grey[400],
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isDisabled ? Colors.grey[300]! : Colors.blue[200]!,
        width: 1,
      ),
      animationStyle: AnimationStyle.bounce,
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget action({
    required VoidCallback? onPressed,
    required IconData icon,
    Color? color,
    String? tooltip,
  }) {
    Widget button = AnimatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      color: color ?? Colors.grey[600],
      backgroundColor: Colors.grey[100],
      size: 44,
      animationStyle: AnimationStyle.scale,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  static Widget primary({
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
  }) {
    return AnimatedButton.primary(
      onPressed: onPressed,
      width: width,
      animationStyle: AnimationStyle.scale,
      child: child,
    );
  }

  static Widget secondary({
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
  }) {
    return AnimatedButton.secondary(
      onPressed: onPressed,
      width: width,
      animationStyle: AnimationStyle.scale,
      child: child,
    );
  }
}
