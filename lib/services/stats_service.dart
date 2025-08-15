import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_stats.dart';
import '../utils/constants.dart';

/// Service responsable de la gestion des statistiques et du scoreboard
class StatsService {
  static StatsService? _instance;
  static StatsService get instance => _instance ??= StatsService._();

  StatsService._();

  PlayerStats? _cachedStats;

  /// Charge les statistiques du joueur
  Future<PlayerStats> loadPlayerStats() async {
    if (_cachedStats != null) return _cachedStats!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final statsData = prefs.getString(GameConstants.playerStatsKey);

      if (statsData == null) {
        _cachedStats = PlayerStats.empty();
      } else {
        final json = jsonDecode(statsData);
        _cachedStats = PlayerStats.fromJson(json);
      }

      return _cachedStats!;
    } catch (e) {
      // En cas d'erreur, retourner des stats vides
      _cachedStats = PlayerStats.empty();
      return _cachedStats!;
    }
  }

  /// Sauvegarde les statistiques du joueur
  Future<bool> savePlayerStats(PlayerStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(stats.toJson());
      await prefs.setString(GameConstants.playerStatsKey, statsJson);

      _cachedStats = stats;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enregistre une nouvelle partie terminée
  Future<bool> recordCompletedGame(GameSession session) async {
    if (!session.isCompleted) return false;

    try {
      final stats = await loadPlayerStats();
      final record = GameRecord.fromSession(session);

      // Créer une nouvelle liste de parties récentes
      final updatedRecentGames = List<GameRecord>.from(stats.recentGames);
      updatedRecentGames.add(record);

      // Limiter la taille de l'historique
      if (updatedRecentGames.length > ScoreConstants.maxRecentGames) {
        updatedRecentGames.removeAt(0);
      }

      // Mettre à jour les statistiques par difficulté
      final currentDifficultyStats = stats.statsByDifficulty[session.difficulty] ?? DifficultyStats.empty();
      final updatedDifficultyStats = _updateDifficultyStats(currentDifficultyStats, session);

      // Créer les nouvelles statistiques
      final updatedStatsByDifficulty = Map<Difficulty, DifficultyStats>.from(stats.statsByDifficulty);
      updatedStatsByDifficulty[session.difficulty] = updatedDifficultyStats;

      final updatedStats = PlayerStats(
        statsByDifficulty: updatedStatsByDifficulty,
        recentGames: updatedRecentGames,
      );

      return await savePlayerStats(updatedStats);
    } catch (e) {
      return false;
    }
  }

  /// Enregistre une partie commencée (pour les statistiques)
  Future<bool> recordStartedGame(Difficulty difficulty) async {
    try {
      final stats = await loadPlayerStats();
      final currentDifficultyStats = stats.statsByDifficulty[difficulty] ?? DifficultyStats.empty();

      final updatedDifficultyStats = DifficultyStats(
        gamesPlayed: currentDifficultyStats.gamesPlayed + 1,
        gamesCompleted: currentDifficultyStats.gamesCompleted,
        bestScore: currentDifficultyStats.bestScore,
        bestTimeInSeconds: currentDifficultyStats.bestTimeInSeconds,
        averageTimeInSeconds: currentDifficultyStats.averageTimeInSeconds,
        totalHintsUsed: currentDifficultyStats.totalHintsUsed,
      );

      final updatedStatsByDifficulty = Map<Difficulty, DifficultyStats>.from(stats.statsByDifficulty);
      updatedStatsByDifficulty[difficulty] = updatedDifficultyStats;

      final updatedStats = PlayerStats(
        statsByDifficulty: updatedStatsByDifficulty,
        recentGames: stats.recentGames,
      );

      return await savePlayerStats(updatedStats);
    } catch (e) {
      return false;
    }
  }

  /// Met à jour les statistiques d'une difficulté avec une nouvelle partie
  DifficultyStats _updateDifficultyStats(DifficultyStats currentStats, GameSession session) {
    final newGamesCompleted = currentStats.gamesCompleted + 1;
    final newBestScore = session.score > currentStats.bestScore ? session.score : currentStats.bestScore;

    int newBestTime = currentStats.bestTimeInSeconds;
    if (currentStats.bestTimeInSeconds == 0 || session.durationInSeconds < currentStats.bestTimeInSeconds) {
      newBestTime = session.durationInSeconds;
    }

    // Calcul de la nouvelle moyenne des temps
    double newAverageTime;
    if (currentStats.gamesCompleted == 0) {
      newAverageTime = session.durationInSeconds.toDouble();
    } else {
      final totalTime = (currentStats.averageTimeInSeconds * currentStats.gamesCompleted) + session.durationInSeconds;
      newAverageTime = totalTime / newGamesCompleted;
    }

    return DifficultyStats(
      gamesPlayed: currentStats.gamesPlayed,
      gamesCompleted: newGamesCompleted,
      bestScore: newBestScore,
      bestTimeInSeconds: newBestTime,
      averageTimeInSeconds: newAverageTime,
      totalHintsUsed: currentStats.totalHintsUsed + session.hintsUsed,
    );
  }

  /// Obtient le top des scores (toutes difficultés confondues)
  Future<List<GameRecord>> getTopScores({int limit = 10}) async {
    final stats = await loadPlayerStats();
    final sortedGames = List<GameRecord>.from(stats.recentGames);
    sortedGames.sort((a, b) => b.score.compareTo(a.score));
    return sortedGames.take(limit).toList();
  }

  /// Obtient le top des temps (par difficulté)
  Future<List<GameRecord>> getTopTimes(Difficulty difficulty, {int limit = 10}) async {
    final stats = await loadPlayerStats();
    final filteredGames = stats.recentGames.where((game) => game.difficulty == difficulty).toList();
    filteredGames.sort((a, b) => a.durationInSeconds.compareTo(b.durationInSeconds));
    return filteredGames.take(limit).toList();
  }

  /// Obtient les parties récentes
  Future<List<GameRecord>> getRecentGames({int limit = 20}) async {
    final stats = await loadPlayerStats();
    final recentGames = List<GameRecord>.from(stats.recentGames);
    recentGames.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return recentGames.take(limit).toList();
  }

  /// Obtient les statistiques pour une difficulté spécifique
  Future<DifficultyStats> getStatsForDifficulty(Difficulty difficulty) async {
    final stats = await loadPlayerStats();
    return stats.statsByDifficulty[difficulty] ?? DifficultyStats.empty();
  }

  /// Obtient le rang actuel du joueur pour une difficulté (simulation)
  Future<PlayerRank> getPlayerRank(Difficulty difficulty) async {
    final stats = await getStatsForDifficulty(difficulty);

    // Simulation d'un rang basé sur les performances
    String rank = 'Débutant';
    Color rankColor = Colors.grey;

    if (stats.gamesCompleted >= 1) {
      if (stats.averageTimeInSeconds > 0 && stats.averageTimeInSeconds <= difficulty.targetTime * 0.7) {
        rank = 'Expert';
        rankColor = Colors.purple;
      } else if (stats.averageTimeInSeconds <= difficulty.targetTime) {
        rank = 'Confirmé';
        rankColor = Colors.blue;
      } else if (stats.completionRate >= 70) {
        rank = 'Intermédiaire';
        rankColor = Colors.green;
      } else if (stats.completionRate >= 30) {
        rank = 'Apprenti';
        rankColor = Colors.orange;
      } else {
        rank = 'Novice';
        rankColor = Colors.red;
      }
    }

    return PlayerRank(
      title: rank,
      color: rankColor,
      gamesRequired: _getGamesRequiredForNextRank(stats),
    );
  }

  /// Calcule le nombre de parties requis pour le prochain rang
  int _getGamesRequiredForNextRank(DifficultyStats stats) {
    if (stats.gamesCompleted < 5) return 5 - stats.gamesCompleted;
    if (stats.gamesCompleted < 20) return 20 - stats.gamesCompleted;
    if (stats.gamesCompleted < 50) return 50 - stats.gamesCompleted;
    return 0; // Rang maximum atteint
  }

  /// Remet à zéro toutes les statistiques
  Future<bool> resetAllStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(GameConstants.playerStatsKey);
      _cachedStats = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Exporte les statistiques (pour backup ou partage)
  Future<String?> exportStats() async {
    try {
      final stats = await loadPlayerStats();
      return jsonEncode(stats.toJson());
    } catch (e) {
      return null;
    }
  }

  /// Importe des statistiques (depuis backup)
  Future<bool> importStats(String statsJson) async {
    try {
      final json = jsonDecode(statsJson);
      final stats = PlayerStats.fromJson(json);
      return await savePlayerStats(stats);
    } catch (e) {
      return false;
    }
  }

  /// Invalide le cache (utile lors de tests ou reset)
  void clearCache() {
    _cachedStats = null;
  }
}

/// Modèle pour le rang du joueur
class PlayerRank {
  final String title;
  final Color color;
  final int gamesRequired;

  const PlayerRank({
    required this.title,
    required this.color,
    required this.gamesRequired,
  });
}
