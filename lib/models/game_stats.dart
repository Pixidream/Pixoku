import '../utils/constants.dart';

/// Modèle pour les statistiques d'une partie en cours
class GameSession {
  final DateTime startTime;
  final Difficulty difficulty;
  int hintsUsed;
  int errorsCount;
  bool isCompleted;
  DateTime? endTime;

  GameSession({
    required this.startTime,
    required this.difficulty,
    this.hintsUsed = 0,
    this.errorsCount = 0,
    this.isCompleted = false,
    this.endTime,
  });

  /// Durée de la partie en secondes
  int get durationInSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  /// Durée formatée (HH:mm:ss)
  String get formattedDuration {
    final duration = Duration(seconds: durationInSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calcule le score de la partie
  int get score {
    if (!isCompleted) return 0;

    int baseScore = difficulty.baseScore;
    int timeBonus = _calculateTimeBonus();
    int hintPenalty = hintsUsed * ScoreConstants.hintPenalty;
    int errorPenalty = errorsCount * ScoreConstants.errorPenalty;

    return (baseScore + timeBonus - hintPenalty - errorPenalty).clamp(0, 999999);
  }

  /// Calcule le bonus de temps
  int _calculateTimeBonus() {
    int timeLimit = difficulty.targetTime;
    if (durationInSeconds <= timeLimit) {
      return ((timeLimit - durationInSeconds) * ScoreConstants.timeMultiplier).round();
    }
    return 0;
  }

  /// Termine la partie
  void complete() {
    isCompleted = true;
    endTime = DateTime.now();
  }

  /// Convertit en Map pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'difficulty': difficulty.index,
      'hintsUsed': hintsUsed,
      'errorsCount': errorsCount,
      'isCompleted': isCompleted,
      'endTime': endTime?.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      startTime: DateTime.parse(json['startTime']),
      difficulty: Difficulty.values[json['difficulty']],
      hintsUsed: json['hintsUsed'] ?? 0,
      errorsCount: json['errorsCount'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}

/// Modèle pour l'historique d'une partie terminée
class GameRecord {
  final DateTime completedAt;
  final Difficulty difficulty;
  final int durationInSeconds;
  final int score;
  final int hintsUsed;
  final int errorsCount;

  const GameRecord({
    required this.completedAt,
    required this.difficulty,
    required this.durationInSeconds,
    required this.score,
    required this.hintsUsed,
    required this.errorsCount,
  });

  /// Durée formatée
  String get formattedDuration {
    final duration = Duration(seconds: durationInSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Date formatée (DD/MM/YYYY)
  String get formattedDate {
    return '${completedAt.day.toString().padLeft(2, '0')}/'
           '${completedAt.month.toString().padLeft(2, '0')}/'
           '${completedAt.year}';
  }

  /// Crée depuis une session terminée
  factory GameRecord.fromSession(GameSession session) {
    return GameRecord(
      completedAt: session.endTime!,
      difficulty: session.difficulty,
      durationInSeconds: session.durationInSeconds,
      score: session.score,
      hintsUsed: session.hintsUsed,
      errorsCount: session.errorsCount,
    );
  }

  /// Convertit en Map pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'completedAt': completedAt.toIso8601String(),
      'difficulty': difficulty.index,
      'durationInSeconds': durationInSeconds,
      'score': score,
      'hintsUsed': hintsUsed,
      'errorsCount': errorsCount,
    };
  }

  /// Crée depuis un Map
  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      completedAt: DateTime.parse(json['completedAt']),
      difficulty: Difficulty.values[json['difficulty']],
      durationInSeconds: json['durationInSeconds'],
      score: json['score'],
      hintsUsed: json['hintsUsed'],
      errorsCount: json['errorsCount'],
    );
  }
}

/// Statistiques globales du joueur
class PlayerStats {
  final Map<Difficulty, DifficultyStats> statsByDifficulty;
  final List<GameRecord> recentGames;

  const PlayerStats({
    required this.statsByDifficulty,
    required this.recentGames,
  });

  /// Nombre total de parties jouées
  int get totalGames {
    return statsByDifficulty.values
        .map((stats) => stats.gamesPlayed)
        .fold(0, (a, b) => a + b);
  }

  /// Score total
  int get totalScore {
    return recentGames
        .map((game) => game.score)
        .fold(0, (a, b) => a + b);
  }

  /// Meilleur score global
  int get bestScore {
    if (recentGames.isEmpty) return 0;
    return recentGames.map((game) => game.score).reduce((a, b) => a > b ? a : b);
  }

  /// Temps moyen global (en secondes)
  double get averageTime {
    if (recentGames.isEmpty) return 0;
    final totalTime = recentGames
        .map((game) => game.durationInSeconds)
        .fold(0, (a, b) => a + b);
    return totalTime / recentGames.length;
  }

  /// Statistiques pour une difficulté spécifique
  DifficultyStats? statsFor(Difficulty difficulty) {
    return statsByDifficulty[difficulty];
  }

  /// Crée des stats vides
  factory PlayerStats.empty() {
    return PlayerStats(
      statsByDifficulty: {
        for (var difficulty in Difficulty.values)
          difficulty: DifficultyStats.empty()
      },
      recentGames: [],
    );
  }

  /// Convertit en Map pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'statsByDifficulty': {
        for (var entry in statsByDifficulty.entries)
          entry.key.name: entry.value.toJson()
      },
      'recentGames': recentGames.map((game) => game.toJson()).toList(),
    };
  }

  /// Crée depuis un Map
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      statsByDifficulty: {
        for (var entry in (json['statsByDifficulty'] as Map<String, dynamic>).entries)
          Difficulty.values.firstWhere((d) => d.name == entry.key):
              DifficultyStats.fromJson(entry.value)
      },
      recentGames: (json['recentGames'] as List)
          .map((game) => GameRecord.fromJson(game))
          .toList(),
    );
  }
}

/// Statistiques pour une difficulté spécifique
class DifficultyStats {
  final int gamesPlayed;
  final int gamesCompleted;
  final int bestScore;
  final int bestTimeInSeconds;
  final double averageTimeInSeconds;
  final int totalHintsUsed;

  const DifficultyStats({
    required this.gamesPlayed,
    required this.gamesCompleted,
    required this.bestScore,
    required this.bestTimeInSeconds,
    required this.averageTimeInSeconds,
    required this.totalHintsUsed,
  });

  /// Taux de completion en pourcentage
  double get completionRate {
    if (gamesPlayed == 0) return 0;
    return (gamesCompleted / gamesPlayed) * 100;
  }

  /// Meilleur temps formaté
  String get formattedBestTime {
    if (bestTimeInSeconds == 0) return '--:--';
    final duration = Duration(seconds: bestTimeInSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Temps moyen formaté
  String get formattedAverageTime {
    if (averageTimeInSeconds == 0) return '--:--';
    final duration = Duration(seconds: averageTimeInSeconds.round());
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Crée des stats vides
  factory DifficultyStats.empty() {
    return const DifficultyStats(
      gamesPlayed: 0,
      gamesCompleted: 0,
      bestScore: 0,
      bestTimeInSeconds: 0,
      averageTimeInSeconds: 0,
      totalHintsUsed: 0,
    );
  }

  /// Convertit en Map pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesCompleted': gamesCompleted,
      'bestScore': bestScore,
      'bestTimeInSeconds': bestTimeInSeconds,
      'averageTimeInSeconds': averageTimeInSeconds,
      'totalHintsUsed': totalHintsUsed,
    };
  }

  /// Crée depuis un Map
  factory DifficultyStats.fromJson(Map<String, dynamic> json) {
    return DifficultyStats(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesCompleted: json['gamesCompleted'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      bestTimeInSeconds: json['bestTimeInSeconds'] ?? 0,
      averageTimeInSeconds: (json['averageTimeInSeconds'] ?? 0.0).toDouble(),
      totalHintsUsed: json['totalHintsUsed'] ?? 0,
    );
  }
}

/// Extension pour ajouter les propriétés de scoring aux difficultés
extension DifficultyScoring on Difficulty {
  /// Score de base selon la difficulté
  int get baseScore {
    switch (this) {
      case Difficulty.facile:
        return ScoreConstants.baseScoreFacile;
      case Difficulty.moyen:
        return ScoreConstants.baseScoreMoyen;
      case Difficulty.difficile:
        return ScoreConstants.baseScoreDifficile;
    }
  }

  /// Temps cible en secondes pour le bonus
  int get targetTime {
    switch (this) {
      case Difficulty.facile:
        return ScoreConstants.targetTimeFacile;
      case Difficulty.moyen:
        return ScoreConstants.targetTimeMoyen;
      case Difficulty.difficile:
        return ScoreConstants.targetTimeDifficile;
    }
  }
}

/// Constantes pour le système de scoring
class ScoreConstants {
  // Scores de base par difficulté
  static const int baseScoreFacile = 1000;
  static const int baseScoreMoyen = 2000;
  static const int baseScoreDifficile = 3000;

  // Temps cibles en secondes pour les bonus
  static const int targetTimeFacile = 600;   // 10 minutes
  static const int targetTimeMoyen = 900;    // 15 minutes
  static const int targetTimeDifficile = 1800; // 30 minutes

  // Multiplicateurs et pénalités
  static const double timeMultiplier = 2.0;
  static const int hintPenalty = 50;
  static const int errorPenalty = 25;

  // Limites pour l'historique
  static const int maxRecentGames = 100;
}
