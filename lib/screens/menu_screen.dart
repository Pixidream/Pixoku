import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/theme_service.dart';
import '../utils/constants.dart';
import '../widgets/stats_widget.dart';
import '../widgets/scoreboard_widget.dart';
import '../widgets/theme_selector.dart';
import 'game_screen.dart';

/// Écran de menu principal de l'application
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ThemeService _themeService = ThemeService.instance;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _themeService.backgroundGradient,
        ),
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              width: UIConstants.menuCardWidth,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppTexts.appTitle,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _themeService.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppTexts.chooseLevel,
                    style: TextStyle(
                      fontSize: 16,
                      color: _themeService.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...Difficulty.values.map((difficulty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _buildDifficultyButton(
                        context,
                        difficulty.displayName,
                        difficulty.color,
                        difficulty,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _loadGame(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(AppTexts.continueGame),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeService.colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showStats(context),
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('Statistiques'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showScoreboard(context),
                          icon: const Icon(Icons.leaderboard),
                          label: const Text('Classement'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showThemes(context),
                          icon: const Icon(Icons.palette),
                          label: const Text('Thèmes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _themeService.colors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: const QuickThemeSwitch(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construit un bouton de sélection de difficulté
  Widget _buildDifficultyButton(
    BuildContext context,
    String label,
    Color color,
    Difficulty difficulty,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startNewGame(context, difficulty),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(label),
      ),
    );
  }

  /// Démarre une nouvelle partie en vérifiant s'il existe une sauvegarde
  void _startNewGame(BuildContext context, Difficulty difficulty) async {
    final gameService = GameService.instance;
    final hasSave = await gameService.hasSavedGame();

    if (hasSave && context.mounted) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(AppTexts.gameInProgressTitle),
          content: const Text(AppTexts.gameInProgressMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonNewGame,
              ),
              child: const Text(AppTexts.newGame),
            ),
          ],
        ),
      );

      if (shouldContinue != true) return;

      // Supprimer la sauvegarde existante
      await gameService.deleteSave();
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(difficulty: difficulty),
        ),
      );
    }
  }

  /// Charge une partie sauvegardée existante
  void _loadGame(BuildContext context) async {
    final gameService = GameService.instance;
    final saveData = await gameService.loadGame();

    if (saveData != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(saveData: saveData),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.noSavedGame)),
      );
    }
  }

  /// Affiche le dialog des statistiques
  void _showStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StatsDialog(),
    );
  }

  /// Affiche le dialog du scoreboard
  void _showScoreboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ScoreboardDialog(),
    );
  }

  /// Affiche le dialog de sélection de thème
  void _showThemes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }
}
