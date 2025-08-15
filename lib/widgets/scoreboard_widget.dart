import 'package:flutter/material.dart';
import '../models/game_stats.dart';
import '../services/stats_service.dart';
import '../utils/constants.dart';

/// Widget pour afficher le scoreboard et l'historique des parties
class ScoreboardWidget extends StatefulWidget {
  const ScoreboardWidget({super.key});

  @override
  State<ScoreboardWidget> createState() => _ScoreboardWidgetState();
}

class _ScoreboardWidgetState extends State<ScoreboardWidget> with SingleTickerProviderStateMixin {
  final StatsService _statsService = StatsService.instance;

  late TabController _tabController;
  List<GameRecord> _topScores = [];
  List<GameRecord> _recentGames = [];
  Difficulty? _selectedDifficulty;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScoreboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadScoreboard() async {
    setState(() => _isLoading = true);

    try {
      final topScores = await _statsService.getTopScores(limit: 20);
      final recentGames = await _statsService.getRecentGames(limit: 30);

      setState(() {
        _topScores = topScores;
        _recentGames = recentGames;
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

    return Column(
      children: [
        _buildDifficultyFilter(),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTopScores(),
              _buildRecentGames(),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.emoji_events),
                text: 'Meilleurs scores',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Parties récentes',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit le filtre de difficulté
  Widget _buildDifficultyFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer par difficulté',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDifficultyChip('Tous', null),
                ...Difficulty.values.map((difficulty) =>
                  _buildDifficultyChip(
                    difficulty.displayName,
                    difficulty,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construit un chip de filtre de difficulté
  Widget _buildDifficultyChip(String label, Difficulty? difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    final color = difficulty?.color ?? Colors.grey;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? difficulty : null;
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Construit la liste des meilleurs scores
  Widget _buildTopScores() {
    final filteredScores = _topScores.where((game) =>
        _selectedDifficulty == null || game.difficulty == _selectedDifficulty
    ).toList();

    if (filteredScores.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun score enregistré',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Terminez vos premières parties pour voir vos scores ici !',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredScores.length,
      itemBuilder: (context, index) {
        final game = filteredScores[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildScoreCard(game, index + 1, true),
        );
      },
    );
  }

  /// Construit la liste des parties récentes
  Widget _buildRecentGames() {
    final filteredGames = _recentGames.where((game) =>
        _selectedDifficulty == null || game.difficulty == _selectedDifficulty
    ).toList();

    if (filteredGames.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune partie récente',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Jouez vos premières parties pour voir l\'historique ici !',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildScoreCard(game, null, false),
        );
      },
    );
  }

  /// Construit une carte de score/partie
  Widget _buildScoreCard(GameRecord game, int? rank, bool showScore) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: game.difficulty.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Rang ou icône
            if (rank != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: game.difficulty.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time,
                  color: game.difficulty.color,
                  size: 18,
                ),
              ),

            const SizedBox(width: 12),

            // Informations de la partie
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: game.difficulty.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        game.difficulty.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (!showScore)
                        Text(
                          game.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        game.formattedDuration,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (game.hintsUsed > 0) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.lightbulb,
                          size: 16,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.hintsUsed.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      if (game.errorsCount > 0) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.errorsCount.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatScore(game.score),
                  style: TextStyle(
                    fontSize: showScore ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: showScore ? game.difficulty.color : Colors.grey[700],
                  ),
                ),
                if (showScore)
                  Text(
                    'points',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Obtient la couleur du rang (or, argent, bronze)
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Or
      case 2:
        return Colors.grey; // Argent
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.blue;
    }
  }

  /// Formate un score avec des séparateurs de milliers
  String _formatScore(int score) {
    if (score == 0) return '0';
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Widget pour afficher le scoreboard dans un dialog
class ScoreboardDialog extends StatelessWidget {
  const ScoreboardDialog({super.key});

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
                  const Icon(Icons.leaderboard, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      AppTexts.scoreboard,
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
            const Expanded(child: ScoreboardWidget()),
          ],
        ),
      ),
    );
  }
}
