import 'package:flutter/material.dart';
import '../models/game_stats.dart';
import '../services/stats_service.dart';
import '../utils/constants.dart';

/// Widget pour afficher les statistiques du joueur
class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  final StatsService _statsService = StatsService.instance;
  PlayerStats? _stats;
  Map<Difficulty, PlayerRank> _ranks = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _statsService.loadPlayerStats();
      final ranks = <Difficulty, PlayerRank>{};

      for (final difficulty in Difficulty.values) {
        ranks[difficulty] = await _statsService.getPlayerRank(difficulty);
      }

      setState(() {
        _stats = stats;
        _ranks = ranks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats == null) {
      return const Center(
        child: Text(AppTexts.noGamesPlayed),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStats(),
          const SizedBox(height: 24),
          _buildDifficultyStats(),
          const SizedBox(height: 24),
          _buildRankings(),
        ],
      ),
    );
  }

  /// Construit les statistiques globales
  Widget _buildOverallStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques générales',
              style: TextStyle(
                fontSize: UIConstants.scoreFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    AppTexts.totalGames,
                    _stats!.totalGames.toString(),
                    Icons.games,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    AppTexts.totalScore,
                    _formatScore(_stats!.totalScore),
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Meilleur score',
                    _formatScore(_stats!.bestScore),
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    AppTexts.averageTime,
                    _formatTime(_stats!.averageTime),
                    Icons.timer,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construit les statistiques par difficulté
  Widget _buildDifficultyStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques par difficulté',
              style: TextStyle(
                fontSize: UIConstants.scoreFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...Difficulty.values.map((difficulty) {
              final stats = _stats!.statsByDifficulty[difficulty] ?? DifficultyStats.empty();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDifficultyCard(difficulty, stats),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Construit une carte pour une difficulté spécifique
  Widget _buildDifficultyCard(Difficulty difficulty, DifficultyStats stats) {
    final rank = _ranks[difficulty];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: difficulty.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: difficulty.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: difficulty.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    difficulty.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (rank != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rank.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rank.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats.gamesPlayed.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Jouées', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats.gamesCompleted.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Terminées', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${stats.completionRate.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Réussite', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats.formattedBestTime,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Meilleur', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (stats.gamesCompleted > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stats.completionRate / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(difficulty.color),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit la section des rangs
  Widget _buildRankings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rangs et Progression',
              style: TextStyle(
                fontSize: UIConstants.scoreFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...Difficulty.values.map((difficulty) {
              final rank = _ranks[difficulty];
              if (rank == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRankItem(difficulty, rank),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Construit un item de rang
  Widget _buildRankItem(Difficulty difficulty, PlayerRank rank) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: difficulty.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            difficulty.displayName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rank.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            rank.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (rank.gamesRequired > 0) ...[
          const SizedBox(width: 8),
          Text(
            '+${rank.gamesRequired}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// Construit un item de statistique
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Formate un score avec des séparateurs de milliers
  String _formatScore(int score) {
    if (score == 0) return '0';
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formate un temps en double vers une chaîne lisible
  String _formatTime(double seconds) {
    if (seconds == 0) return '--:--';
    final duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Widget pour afficher les statistiques dans un dialog
class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9;
    final maxHeight = screenSize.height * 0.85;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth > 600 ? 600 : maxWidth,
          maxHeight: maxHeight > 700 ? 700 : maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      AppTexts.statistics,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Expanded(child: StatsWidget()),
          ],
        ),
      ),
    );
  }
}
