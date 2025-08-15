import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  // Animation controllers pour différents types d'animations
  static const Duration _defaultDuration = Duration(milliseconds: 200);  // Réduit de 300ms à 200ms
  static const Duration _fastDuration = Duration(milliseconds: 100);     // Réduit de 150ms à 100ms
  static const Duration _slowDuration = Duration(milliseconds: 350);     // Réduit de 500ms à 350ms

  // Animation pour la sélection de cellule
  static Animation<double> createCellSelectionAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.03,  // Réduit de 1.1 à 1.03 pour un effet plus subtil
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,  // Utiliser easeOutBack au lieu d'elasticOut pour éviter les dépassements
    ));
  }

  // Animation pour le remplissage de cellule
  static Animation<double> createCellFillAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.bounceOut,
    ));
  }

  // Animation d'erreur (shake)
  static Animation<double> createShakeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,  // Linéaire car on applique la courbe dans le widget
    ));
  }

  // Animation de succès (scale + rotation)
  static Animation<double> createSuccessScaleAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.95,  // Réduit l'amplitude du scale
      end: 1.05,    // Réduit de 1.2 à 1.05
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.bounceOut,  // Utiliser bounceOut au lieu d'elasticOut pour éviter les dépassements
    ));
  }

  static Animation<double> createSuccessRotationAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Animation de fadeIn pour les éléments d'interface
  static Animation<double> createFadeInAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));
  }

  // Animation de slideUp pour les popups
  static Animation<Offset> createSlideUpAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));
  }

  // Animation de bounce pour les boutons
  static Animation<double> createButtonBounceAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Animation de highlight pour les régions (blocs, lignes, colonnes)
  static Animation<double> createHighlightAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Animation de progress pour le timer
  static Animation<double> createProgressAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));
  }

  // Animation de completion pour finir le jeu
  static Animation<double> createCompletionAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.bounceOut,
    ));
  }

  // Animation de pulse pour les éléments importants
  static Animation<double> createPulseAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.02,  // Réduit de 1.05 à 1.02 pour un pulse plus subtil
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Animation pour les transitions de page
  static Widget createPageTransition({
    required Widget child,
    required Animation<double> animation,
    PageTransitionType type = PageTransitionType.slideUp,
  }) {
    switch (type) {
      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );
    }
  }

  // Widget pour l'animation de shake
  static Widget createShakeWidget({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        // Utiliser sin pour créer l'effet de shake avec atténuation
        final double progress = animation.value.clamp(0.0, 1.0);  // S'assurer que la valeur est dans [0,1]
        final double offset = math.sin(progress * math.pi * 3) * 4 * (1 - progress);  // Réduit de 10 à 4 pixels et de 4 oscillations à 3
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
    );
  }

  // Widget pour l'animation de bounce
  static Widget createBounceWidget({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value.clamp(0.0, 2.0),  // Clamper pour éviter les valeurs extrêmes
          child: child,
        );
      },
    );
  }

  // Widget pour l'animation de pulse
  static Widget createPulseWidget({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final double clampedValue = animation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 1.0 + (clampedValue * 0.05),  // Réduit de 0.1 à 0.05 pour un pulse plus doux
          child: child,
        );
      },
    );
  }

  // Widget pour l'animation de rotation de succès
  static Widget createSuccessRotationWidget({
    required Widget child,
    required Animation<double> scaleAnimation,
    required Animation<double> rotationAnimation,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, rotationAnimation]),
      child: child,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value.clamp(0.5, 1.5),  // Limiter le scale pour éviter les extrêmes
          child: Transform.rotate(
            angle: rotationAnimation.value.clamp(-math.pi, math.pi),  // Limiter la rotation
            child: child,
          ),
        );
      },
    );
  }

  // Méthodes utilitaires pour créer des controllers avec durées prédéfinies
  static AnimationController createDefaultController(TickerProvider vsync) {
    return AnimationController(
      duration: _defaultDuration,
      vsync: vsync,
    );
  }

  static AnimationController createFastController(TickerProvider vsync) {
    return AnimationController(
      duration: _fastDuration,
      vsync: vsync,
    );
  }

  static AnimationController createSlowController(TickerProvider vsync) {
    return AnimationController(
      duration: _slowDuration,
      vsync: vsync,
    );
  }

  static AnimationController createCustomController(
    TickerProvider vsync,
    Duration duration
  ) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  // Méthodes pour jouer des séquences d'animations
  static Future<void> playSequence(List<AnimationController> controllers) async {
    for (final controller in controllers) {
      await controller.forward();
    }
  }

  static Future<void> playParallel(List<AnimationController> controllers) async {
    final futures = controllers.map((c) => c.forward()).toList();
    await Future.wait(futures);
  }

  // Méthode pour reset tous les controllers
  static void resetControllers(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.reset();
    }
  }
}

// Enum pour les types de transitions de page
enum PageTransitionType {
  slideUp,
  slideRight,
  fade,
  scale,
}

// Classe pour les configurations d'animation
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final double? beginValue;
  final double? endValue;

  const AnimationConfig({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.beginValue,
    this.endValue,
  });

  static const AnimationConfig fast = AnimationConfig(
    duration: Duration(milliseconds: 100),  // Réduit de 150ms à 100ms
    curve: Curves.easeOut,
  );

  static const AnimationConfig slow = AnimationConfig(
    duration: Duration(milliseconds: 350),  // Réduit de 500ms à 350ms
    curve: Curves.easeInOut,
  );

  static const AnimationConfig bounce = AnimationConfig(
    duration: Duration(milliseconds: 250),  // Réduit de 400ms à 250ms
    curve: Curves.bounceOut,
  );

  static const AnimationConfig elastic = AnimationConfig(
    duration: Duration(milliseconds: 400),  // Réduit de 600ms à 400ms
    curve: Curves.elasticOut,
  );
}
