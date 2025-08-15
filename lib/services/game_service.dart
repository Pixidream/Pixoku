import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_puzzle.dart';
import '../utils/constants.dart';

/// Service responsable de la sauvegarde et du chargement des parties
class GameService {
  static GameService? _instance;
  static GameService get instance => _instance ??= GameService._();

  GameService._();

  /// Sauvegarde l'état actuel de la partie
  Future<bool> saveGame({
    required SudokuPuzzle puzzle,
    required int hintsRemaining,
    required Difficulty difficulty,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final saveData = {
        'grid': puzzle.grid,
        'solution': puzzle.solution,
        'isFixed': puzzle.isFixed,
        'hintsRemaining': hintsRemaining,
        'difficulty': difficulty.index,
        'savedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(AppTexts.saveKey, json.encode(saveData));
      return true;
    } catch (e) {
      // Log l'erreur en mode debug
      assert(false, 'Erreur lors de la sauvegarde: $e');
      return false;
    }
  }

  /// Charge une partie sauvegardée
  Future<GameSaveData?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameData = prefs.getString(AppTexts.saveKey);

      if (gameData == null) return null;

      final data = json.decode(gameData);
      return GameSaveData.fromJson(data);
    } catch (e) {
      // Log l'erreur en mode debug
      assert(false, 'Erreur lors du chargement: $e');
      return null;
    }
  }

  /// Vérifie s'il existe une partie sauvegardée
  Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(AppTexts.saveKey);
    } catch (e) {
      return false;
    }
  }

  /// Supprime la sauvegarde actuelle
  Future<bool> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppTexts.saveKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtient des informations sur la sauvegarde sans la charger complètement
  Future<GameSaveInfo?> getSaveInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameData = prefs.getString(AppTexts.saveKey);

      if (gameData == null) return null;

      final data = json.decode(gameData);
      return GameSaveInfo(
        difficulty: Difficulty.values[data['difficulty'] ?? 0],
        hintsRemaining: data['hintsRemaining'] ?? GameConstants.initialHints,
        savedAt: DateTime.tryParse(data['savedAt'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Modèle pour les données de sauvegarde complètes
class GameSaveData {
  final SudokuPuzzle puzzle;
  final int hintsRemaining;
  final Difficulty difficulty;
  final DateTime savedAt;

  const GameSaveData({
    required this.puzzle,
    required this.hintsRemaining,
    required this.difficulty,
    required this.savedAt,
  });

  factory GameSaveData.fromJson(Map<String, dynamic> json) {
    return GameSaveData(
      puzzle: SudokuPuzzle.fromJson(json),
      hintsRemaining: json['hintsRemaining'] ?? GameConstants.initialHints,
      difficulty: Difficulty.values[json['difficulty'] ?? 0],
      savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...puzzle.toJson(),
      'hintsRemaining': hintsRemaining,
      'difficulty': difficulty.index,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}

/// Modèle pour les informations de base d'une sauvegarde
class GameSaveInfo {
  final Difficulty difficulty;
  final int hintsRemaining;
  final DateTime savedAt;

  const GameSaveInfo({
    required this.difficulty,
    required this.hintsRemaining,
    required this.savedAt,
  });

  /// Retourne une description formatée de la sauvegarde
  String get description {
    final difficultyText = difficulty.displayName;
    final hintsText = hintsRemaining > 0 ? '$hintsRemaining indices' : 'Plus d\'indices';
    return '$difficultyText • $hintsText';
  }

  /// Retourne le temps écoulé depuis la sauvegarde
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(savedAt);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
