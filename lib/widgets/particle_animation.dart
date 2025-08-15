import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleAnimation extends StatefulWidget {
  final bool isActive;
  final ParticleEffectType effectType;
  final Duration duration;
  final int particleCount;
  final List<Color> colors;
  final double particleSize;
  final VoidCallback? onComplete;
  final Widget? child;

  const ParticleAnimation({
    super.key,
    this.isActive = false,
    this.effectType = ParticleEffectType.confetti,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 50,
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ],
    this.particleSize = 4.0,
    this.onComplete,
    this.child,
  });

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with TickerProviderStateMixin {

  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        if (mounted) {
          setState(() {
            _particles.clear();
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(ParticleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _startAnimation();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    _generateParticles();
    _controller.reset();
    _controller.forward();
  }

  void _stopAnimation() {
    _controller.stop();
    setState(() {
      _particles.clear();
    });
  }

  void _generateParticles() {
    _particles.clear();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_createParticle());
    }

    setState(() {});
  }

  Particle _createParticle() {
    switch (widget.effectType) {
      case ParticleEffectType.confetti:
        return _createConfettiParticle();
      case ParticleEffectType.fireworks:
        return _createFireworkParticle();
      case ParticleEffectType.stars:
        return _createStarParticle();
      case ParticleEffectType.celebration:
        return _createCelebrationParticle();
      case ParticleEffectType.sparkles:
        return _createSparkleParticle();
    }
  }

  Particle _createConfettiParticle() {
    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        -50 + _random.nextDouble() * 100,
      ),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 200,
        _random.nextDouble() * 300 + 100,
      ),
      acceleration: const Offset(0, 200),
      color: widget.colors[_random.nextInt(widget.colors.length)],
      size: widget.particleSize * (0.5 + _random.nextDouble()),
      rotation: _random.nextDouble() * math.pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      life: 1.0,
      decay: 0.3 + _random.nextDouble() * 0.4,
      shape: ParticleShape.rectangle,
    );
  }

  Particle _createFireworkParticle() {
    final angle = _random.nextDouble() * math.pi * 2;
    final speed = 100 + _random.nextDouble() * 200;

    return Particle(
      position: const Offset(200, 300),
      velocity: Offset(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      ),
      acceleration: const Offset(0, 50),
      color: widget.colors[_random.nextInt(widget.colors.length)],
      size: widget.particleSize * (0.3 + _random.nextDouble() * 0.7),
      rotation: 0,
      rotationSpeed: 0,
      life: 1.0,
      decay: 0.4 + _random.nextDouble() * 0.3,
      shape: ParticleShape.circle,
    );
  }

  Particle _createStarParticle() {
    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        _random.nextDouble() * 600,
      ),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 50,
        _random.nextDouble() * 100 + 50,
      ),
      acceleration: const Offset(0, 30),
      color: widget.colors[_random.nextInt(widget.colors.length)],
      size: widget.particleSize * (0.8 + _random.nextDouble() * 0.4),
      rotation: 0,
      rotationSpeed: (_random.nextDouble() - 0.5) * 5,
      life: 1.0,
      decay: 0.2 + _random.nextDouble() * 0.3,
      shape: ParticleShape.star,
    );
  }

  Particle _createCelebrationParticle() {
    final shapes = [ParticleShape.circle, ParticleShape.rectangle, ParticleShape.star];

    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        -50,
      ),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 150,
        _random.nextDouble() * 400 + 200,
      ),
      acceleration: const Offset(0, 150),
      color: widget.colors[_random.nextInt(widget.colors.length)],
      size: widget.particleSize * (0.6 + _random.nextDouble() * 0.8),
      rotation: _random.nextDouble() * math.pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 8,
      life: 1.0,
      decay: 0.25 + _random.nextDouble() * 0.5,
      shape: shapes[_random.nextInt(shapes.length)],
    );
  }

  Particle _createSparkleParticle() {
    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        _random.nextDouble() * 600,
      ),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 30,
        (_random.nextDouble() - 0.5) * 30,
      ),
      acceleration: Offset.zero,
      color: widget.colors[_random.nextInt(widget.colors.length)],
      size: widget.particleSize * (0.3 + _random.nextDouble() * 0.4),
      rotation: 0,
      rotationSpeed: (_random.nextDouble() - 0.5) * 15,
      life: 1.0,
      decay: 0.5 + _random.nextDouble() * 0.3,
      shape: ParticleShape.star,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (widget.isActive)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      _paintParticle(canvas, particle, progress);
    }
  }

  void _paintParticle(Canvas canvas, Particle particle, double progress) {
    final updatedParticle = particle.update(progress);

    if (updatedParticle.life <= 0) return;

    final paint = Paint()
      ..color = updatedParticle.color.withValues(alpha: updatedParticle.life)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(updatedParticle.position.dx, updatedParticle.position.dy);
    canvas.rotate(updatedParticle.rotation);

    switch (updatedParticle.shape) {
      case ParticleShape.circle:
        canvas.drawCircle(Offset.zero, updatedParticle.size / 2, paint);
        break;
      case ParticleShape.rectangle:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: updatedParticle.size,
            height: updatedParticle.size * 0.6,
          ),
          paint,
        );
        break;
      case ParticleShape.star:
        _drawStar(canvas, paint, updatedParticle.size);
        break;
    }

    canvas.restore();
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final radius = size / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5;
      final currentRadius = i.isEven ? radius : innerRadius;
      final x = math.cos(angle) * currentRadius;
      final y = math.sin(angle) * currentRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class Particle {
  Offset position;
  Offset velocity;
  Offset acceleration;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  double life;
  double decay;
  ParticleShape shape;

  Particle({
    required this.position,
    required this.velocity,
    required this.acceleration,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.life,
    required this.decay,
    required this.shape,
  });

  Particle update(double deltaTime) {
    // Update physics
    final newVelocity = velocity + (acceleration * deltaTime);
    final newPosition = position + (newVelocity * deltaTime);
    final newRotation = rotation + (rotationSpeed * deltaTime);
    final newLife = math.max(0.0, life - (decay * deltaTime));

    return Particle(
      position: newPosition,
      velocity: newVelocity,
      acceleration: acceleration,
      color: color,
      size: size,
      rotation: newRotation,
      rotationSpeed: rotationSpeed,
      life: newLife,
      decay: decay,
      shape: shape,
    );
  }
}

enum ParticleEffectType {
  confetti,
  fireworks,
  stars,
  celebration,
  sparkles,
}

enum ParticleShape {
  circle,
  rectangle,
  star,
}

// Pre-built particle effect widgets
class ParticleEffects {

  static Widget victory({
    required bool isActive,
    VoidCallback? onComplete,
    Widget? child,
  }) {
    return ParticleAnimation(
      isActive: isActive,
      effectType: ParticleEffectType.celebration,
      duration: const Duration(seconds: 4),
      particleCount: 80,
      colors: const [
        Colors.amber,
        Colors.orange,
        Colors.red,
        Colors.pink,
        Colors.purple,
        Colors.blue,
      ],
      particleSize: 6.0,
      onComplete: onComplete,
      child: child,
    );
  }

  static Widget confetti({
    required bool isActive,
    VoidCallback? onComplete,
    Widget? child,
  }) {
    return ParticleAnimation(
      isActive: isActive,
      effectType: ParticleEffectType.confetti,
      duration: const Duration(seconds: 3),
      particleCount: 60,
      colors: const [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.pink,
        Colors.cyan,
      ],
      particleSize: 5.0,
      onComplete: onComplete,
      child: child,
    );
  }

  static Widget fireworks({
    required bool isActive,
    VoidCallback? onComplete,
    Widget? child,
  }) {
    return ParticleAnimation(
      isActive: isActive,
      effectType: ParticleEffectType.fireworks,
      duration: const Duration(seconds: 2),
      particleCount: 40,
      colors: const [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
      ],
      particleSize: 4.0,
      onComplete: onComplete,
      child: child,
    );
  }

  static Widget sparkles({
    required bool isActive,
    VoidCallback? onComplete,
    Widget? child,
  }) {
    return ParticleAnimation(
      isActive: isActive,
      effectType: ParticleEffectType.sparkles,
      duration: const Duration(seconds: 2),
      particleCount: 30,
      colors: const [
        Colors.white,
        Colors.yellow,
        Colors.amber,
        Colors.orange,
      ],
      particleSize: 3.0,
      onComplete: onComplete,
      child: child,
    );
  }

  static Widget stars({
    required bool isActive,
    VoidCallback? onComplete,
    Widget? child,
  }) {
    return ParticleAnimation(
      isActive: isActive,
      effectType: ParticleEffectType.stars,
      duration: const Duration(seconds: 3),
      particleCount: 25,
      colors: const [
        Colors.white,
        Colors.yellow,
        Colors.amber,
        Colors.blue,
        Colors.cyan,
      ],
      particleSize: 5.0,
      onComplete: onComplete,
      child: child,
    );
  }
}

// Particle system manager for multiple effects
class ParticleSystem extends StatefulWidget {
  final List<ParticleLayer> layers;
  final Widget? child;

  const ParticleSystem({
    super.key,
    required this.layers,
    this.child,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem> {
  @override
  Widget build(BuildContext context) {
    Widget current = widget.child ?? const SizedBox.expand();

    for (final layer in widget.layers.reversed) {
      current = ParticleAnimation(
        isActive: layer.isActive,
        effectType: layer.effectType,
        duration: layer.duration,
        particleCount: layer.particleCount,
        colors: layer.colors,
        particleSize: layer.particleSize,
        onComplete: layer.onComplete,
        child: current,
      );
    }

    return current;
  }
}

class ParticleLayer {
  final bool isActive;
  final ParticleEffectType effectType;
  final Duration duration;
  final int particleCount;
  final List<Color> colors;
  final double particleSize;
  final VoidCallback? onComplete;

  const ParticleLayer({
    required this.isActive,
    required this.effectType,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 50,
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ],
    this.particleSize = 4.0,
    this.onComplete,
  });
}
