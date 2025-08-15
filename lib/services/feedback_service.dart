import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _isInitialized = false;

  // Préférences pour les réglages
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';

  // Sons disponibles (nous utiliserons des sons système Flutter)
  final Map<FeedbackType, SystemSoundType> _systemSounds = {
    FeedbackType.cellSelect: SystemSoundType.click,
    FeedbackType.numberPlace: SystemSoundType.click,
    FeedbackType.numberRemove: SystemSoundType.click,
    FeedbackType.error: SystemSoundType.alert,
    FeedbackType.success: SystemSoundType.click,
    FeedbackType.gameComplete: SystemSoundType.click,
    FeedbackType.buttonTap: SystemSoundType.click,
    FeedbackType.undo: SystemSoundType.click,
    FeedbackType.hint: SystemSoundType.click,
  };

  // Patterns de vibration
  final Map<FeedbackType, VibrationPattern> _vibrationPatterns = {
    FeedbackType.cellSelect: VibrationPattern.light,
    FeedbackType.numberPlace: VibrationPattern.medium,
    FeedbackType.numberRemove: VibrationPattern.light,
    FeedbackType.error: VibrationPattern.heavy,
    FeedbackType.success: VibrationPattern.success,
    FeedbackType.gameComplete: VibrationPattern.celebration,
    FeedbackType.buttonTap: VibrationPattern.light,
    FeedbackType.undo: VibrationPattern.light,
    FeedbackType.hint: VibrationPattern.medium,
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();
      await _loadSettings();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du FeedbackService: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
      _hapticEnabled = prefs.getBool(_hapticEnabledKey) ?? true;
    } catch (e) {
      debugPrint('Erreur lors du chargement des paramètres de feedback: $e');
    }
  }

  // Getters pour les réglages
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  // Setters avec sauvegarde
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, enabled);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du réglage sonore: $e');
    }
  }

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hapticEnabledKey, enabled);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du réglage haptique: $e');
    }
  }

  // Méthode principale pour jouer un feedback
  Future<void> playFeedback(FeedbackType type) async {
    if (!_isInitialized) {
      await initialize();
    }

    await Future.wait([
      _playSound(type),
      _playHaptic(type),
    ]);
  }

  // Méthodes pour jouer seulement le son ou seulement la vibration
  Future<void> playSound(FeedbackType type) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _playSound(type);
  }

  Future<void> playHaptic(FeedbackType type) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _playHaptic(type);
  }

  Future<void> _playSound(FeedbackType type) async {
    if (!_soundEnabled) return;

    try {
      final systemSound = _systemSounds[type];
      if (systemSound != null) {
        SystemSound.play(systemSound);
      }
    } catch (e) {
      debugPrint('Erreur lors de la lecture du son: $e');
    }
  }

  Future<void> _playHaptic(FeedbackType type) async {
    if (!_hapticEnabled) return;

    try {
      // Vérifier si la vibration est disponible
      final hasVibration = await Vibration.hasVibrator();
      if (!hasVibration!) return;

      final pattern = _vibrationPatterns[type] ?? VibrationPattern.light;
      await _executeVibrationPattern(pattern);
    } catch (e) {
      debugPrint('Erreur lors de la vibration: $e');
    }
  }

  Future<void> _executeVibrationPattern(VibrationPattern pattern) async {
    switch (pattern) {
      case VibrationPattern.light:
        if (Platform.isIOS) {
          await HapticFeedback.lightImpact();
        } else {
          await Vibration.vibrate(duration: 50, amplitude: 50);
        }
        break;

      case VibrationPattern.medium:
        if (Platform.isIOS) {
          await HapticFeedback.mediumImpact();
        } else {
          await Vibration.vibrate(duration: 100, amplitude: 128);
        }
        break;

      case VibrationPattern.heavy:
        if (Platform.isIOS) {
          await HapticFeedback.heavyImpact();
        } else {
          await Vibration.vibrate(duration: 200, amplitude: 255);
        }
        break;

      case VibrationPattern.success:
        if (Platform.isIOS) {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
        } else {
          await Vibration.vibrate(pattern: [0, 100, 50, 50], amplitude: 200);
        }
        break;

      case VibrationPattern.error:
        if (Platform.isIOS) {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact();
        } else {
          await Vibration.vibrate(pattern: [0, 200, 100, 200], amplitude: 255);
        }
        break;

      case VibrationPattern.celebration:
        if (Platform.isIOS) {
          // Pattern de célébration pour iOS
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
        } else {
          // Pattern de célébration pour Android
          await Vibration.vibrate(
            pattern: [0, 150, 50, 100, 50, 150, 50, 100],
            amplitude: 200
          );
        }
        break;
    }
  }

  // Méthodes de feedback spécialisées pour des actions communes
  Future<void> cellSelected() => playFeedback(FeedbackType.cellSelect);
  Future<void> numberPlaced() => playFeedback(FeedbackType.numberPlace);
  Future<void> numberRemoved() => playFeedback(FeedbackType.numberRemove);
  Future<void> errorOccurred() => playFeedback(FeedbackType.error);
  Future<void> successAction() => playFeedback(FeedbackType.success);
  Future<void> gameCompleted() => playFeedback(FeedbackType.gameComplete);
  Future<void> buttonTapped() => playFeedback(FeedbackType.buttonTap);
  Future<void> undoAction() => playFeedback(FeedbackType.undo);
  Future<void> hintUsed() => playFeedback(FeedbackType.hint);

  // Méthodes pour des séquences de feedback
  Future<void> playSequence(List<FeedbackType> types, {Duration delay = const Duration(milliseconds: 100)}) async {
    for (int i = 0; i < types.length; i++) {
      await playFeedback(types[i]);
      if (i < types.length - 1) {
        await Future.delayed(delay);
      }
    }
  }

  // Méthode pour tester les feedbacks (utile pour les réglages)
  Future<void> testFeedback(FeedbackType type) async {
    await playFeedback(type);
  }

  // Nettoyage des ressources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      debugPrint('Erreur lors de la libération des ressources audio: $e');
    }
  }

  // Méthode pour réinitialiser tous les réglages
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_soundEnabledKey);
      await prefs.remove(_hapticEnabledKey);
      _soundEnabled = true;
      _hapticEnabled = true;
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation des réglages: $e');
    }
  }
}

// Énumération des types de feedback
enum FeedbackType {
  cellSelect,
  numberPlace,
  numberRemove,
  error,
  success,
  gameComplete,
  buttonTap,
  undo,
  hint,
}

// Énumération des patterns de vibration
enum VibrationPattern {
  light,
  medium,
  heavy,
  success,
  error,
  celebration,
}

// Extensions utiles pour les types de feedback
extension FeedbackTypeExtension on FeedbackType {
  String get description {
    switch (this) {
      case FeedbackType.cellSelect:
        return 'Sélection de cellule';
      case FeedbackType.numberPlace:
        return 'Placement de nombre';
      case FeedbackType.numberRemove:
        return 'Suppression de nombre';
      case FeedbackType.error:
        return 'Erreur';
      case FeedbackType.success:
        return 'Succès';
      case FeedbackType.gameComplete:
        return 'Jeu terminé';
      case FeedbackType.buttonTap:
        return 'Bouton pressé';
      case FeedbackType.undo:
        return 'Annulation';
      case FeedbackType.hint:
        return 'Indice utilisé';
    }
  }
}
