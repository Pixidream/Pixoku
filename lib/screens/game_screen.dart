import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../models/game_stats.dart';
import '../services/game_service.dart';
import '../services/stats_service.dart';
import '../services/sudoku_generator.dart';
import '../services/theme_service.dart';
import '../services/feedback_service.dart';
import '../utils/constants.dart';
import '../widgets/action_buttons.dart';
import '../widgets/number_pad.dart';
import '../widgets/animated_sudoku_grid.dart';
import '../widgets/animated_popup.dart';
import '../widgets/particle_animation.dart';

/// Écran principal du jeu de Sudoku
class GameScreen extends StatefulWidget {
  final Difficulty? difficulty;
  final GameSaveData? saveData;

  const GameScreen({
    super.key,
    this.difficulty,
    this.saveData,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // État du jeu
  late SudokuPuzzle _puzzle;
  late Difficulty _currentDifficulty;
  int? _selectedRow;
  int? _selectedCol;
  int? _selectedNumber;
  int _hintsRemaining = GameConstants.initialHints;
  bool _isNotesMode = false;

  // Session de jeu et timer
  late GameSession _gameSession;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // Historique des mouvements pour l'annulation
  final List<List<List<int>>> _moveHistory = [];

  // Services
  final GameService _gameService = GameService.instance;
  final StatsService _statsService = StatsService.instance;
  final ThemeService _themeService = ThemeService.instance;
  final FeedbackService _feedbackService = FeedbackService();

  // État des animations et popups
  bool _showVictoryPopup = false;
  bool _showVictoryParticles = false;
  bool _gameCompleted = false;
  bool _enableAnimations = true;

  // Keys pour contrôler les animations
  final GlobalKey<AnimatedSudokuGridState> _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _initializeFeedback();
    _initializeGame();
  }

  Future<void> _initializeFeedback() async {
    await _feedbackService.initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _themeService.removeListener(_onThemeChanged);
    _feedbackService.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  /// Initialise le jeu selon les paramètres fournis
  void _initializeGame() {
    if (widget.saveData != null) {
      _loadFromSave(widget.saveData!);
    } else {
      _currentDifficulty = widget.difficulty!;
      _generateNewPuzzle();
    }
    _startTimer();
  }

  /// Charge une partie depuis une sauvegarde
  void _loadFromSave(GameSaveData saveData) {
    setState(() {
      _puzzle = saveData.puzzle;
      _hintsRemaining = saveData.hintsRemaining;
      _currentDifficulty = saveData.difficulty;
      _selectedRow = null;
      _selectedCol = null;
      _selectedNumber = null;

      // Créer une nouvelle session pour la partie chargée
      _gameSession = GameSession(
        startTime: saveData.savedAt,
        difficulty: _currentDifficulty,
      );
      _elapsedSeconds = _gameSession.durationInSeconds;

      // Initialiser l'historique avec l'état actuel
      _moveHistory.clear();
      _moveHistory.add(_puzzle.grid.map((row) => List<int>.from(row)).toList());
    });
  }

  /// Génère un nouveau puzzle
  void _generateNewPuzzle() {
    final generator = SudokuGenerator();
    final puzzle = generator.generatePuzzle(_currentDifficulty);

    setState(() {
      _puzzle = puzzle;
      _selectedRow = null;
      _selectedCol = null;
      _selectedNumber = null;
      _hintsRemaining = GameConstants.initialHints;
      _elapsedSeconds = 0;

      // Créer une nouvelle session de jeu
      _gameSession = GameSession(
        startTime: DateTime.now(),
        difficulty: _currentDifficulty,
      );

      // Initialiser l'historique avec l'état initial
      _moveHistory.clear();
      _moveHistory.add(_puzzle.grid.map((row) => List<int>.from(row)).toList());
    });

    // Enregistrer le début de partie dans les stats
    _statsService.recordStartedGame(_currentDifficulty);
    _saveGame();
  }

  /// Démarre le timer de jeu
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      },
    );
  }

  /// Arrête le timer de jeu
  void _stopTimer() {
    _timer?.cancel();
  }

  /// Sauvegarde l'état actuel du jeu
  void _saveGame() {
    _gameService.saveGame(
      puzzle: _puzzle,
      hintsRemaining: _hintsRemaining,
      difficulty: _currentDifficulty,
    );
  }

  /// Sauvegarde un mouvement dans l'historique
  void _saveMoveToHistory() {
    _moveHistory.add(_puzzle.grid.map((row) => List<int>.from(row)).toList());

    // Limiter la taille de l'historique
    if (_moveHistory.length > GameConstants.maxMoveHistory) {
      _moveHistory.removeAt(0);
    }
  }

  /// Gère le tap sur une cellule de la grille
  void _onCellTap(int row, int col) {
    setState(() {
      if (_selectedRow == row && _selectedCol == col) {
        // Désélectionner si on tap sur la même cellule
        _selectedRow = null;
        _selectedCol = null;
        _selectedNumber = null;
        _gridKey.currentState?.unhighlightAll();
      } else {
        // Sélectionner la nouvelle cellule
        _selectedRow = row;
        _selectedCol = col;
        _selectedNumber = _puzzle.grid[row][col] == 0 ? null : _puzzle.grid[row][col];

        // Mettre en surbrillance les cellules avec le même nombre
        if (_selectedNumber != null) {
          _gridKey.currentState?.highlightNumber(_selectedNumber!);
        } else {
          _gridKey.currentState?.unhighlightAll();
        }
      }
    });

    _feedbackService.cellSelected();
  }

  /// Gère le tap sur un chiffre du pavé numérique
  void _onNumberTap(int number) {
    if (_selectedRow == null || _selectedCol == null) {
      _feedbackService.errorOccurred();
      return;
    }
    if (_puzzle.isFixed[_selectedRow!][_selectedCol!]) {
      _feedbackService.errorOccurred();
      return;
    }

    _saveMoveToHistory();

    setState(() {
      final newGrid = _puzzle.grid.map((row) => List<int>.from(row)).toList();

      if (_isNotesMode) {
        // Mode notes : basculer la note
        _puzzle = _puzzle.toggleNote(_selectedRow!, _selectedCol!, number);
        _feedbackService.cellSelected();
      } else {
        // Mode normal : placer le nombre
        if (newGrid[_selectedRow!][_selectedCol!] == number) {
          // Effacer si le même nombre est sélectionné
          newGrid[_selectedRow!][_selectedCol!] = 0;
          _selectedNumber = null;
          _feedbackService.numberRemoved();
        } else {
          // Placer le nouveau nombre
          newGrid[_selectedRow!][_selectedCol!] = number;
          _selectedNumber = number;

          // Vérifier si c'est une erreur (valeur invalide)
          if (!_puzzle.isValidMove(_selectedRow!, _selectedCol!, number)) {
            _gameSession.errorsCount++;
            _feedbackService.errorOccurred();
            _gridKey.currentState?.playErrorWave();
          } else {
            _feedbackService.numberPlaced();
          }

          // Nettoyer les notes invalides dans la région
          _puzzle = _puzzle.copyWith(grid: newGrid).clearInvalidNotes(_selectedRow!, _selectedCol!, number);
        }

        if (newGrid[_selectedRow!][_selectedCol!] == 0) {
          _puzzle = _puzzle.copyWith(grid: newGrid);
        }
      }
    });

    _saveGame();

    // Vérifier si le jeu est terminé
    if (_puzzle.isComplete()) {
      _onGameCompleted();
    }
  }

  /// Gère la fin de partie
  void _onGameCompleted() {
    _stopTimer();
    _gameCompleted = true;

    // Finaliser la session de jeu
    _gameSession.complete();

    // Enregistrer dans les statistiques
    _statsService.recordCompletedGame(_gameSession);

    // Déclencher les animations de victoire
    _feedbackService.gameCompleted();
    setState(() {
      _showVictoryParticles = true;
    });

    // Attendre un peu puis montrer le popup de victoire
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showVictoryPopup = true;
        });
      }
    });
  }

  /// Annule le dernier mouvement
  void _undoMove() {
    if (_moveHistory.length <= 1) {
      _feedbackService.errorOccurred();
      return;
    }

    setState(() {
      _moveHistory.removeLast();
      final previousGrid = _moveHistory.last.map((row) => List<int>.from(row)).toList();

      _puzzle = _puzzle.copyWith(grid: previousGrid);
      _selectedNumber = null;
    });

    _feedbackService.undoAction();
    _saveGame();
  }

  /// Efface la cellule sélectionnée
  void _clearCell() {
    if (_selectedRow == null || _selectedCol == null) {
      _feedbackService.errorOccurred();
      return;
    }
    if (_puzzle.isFixed[_selectedRow!][_selectedCol!]) {
      _feedbackService.errorOccurred();
      return;
    }

    _saveMoveToHistory();

    setState(() {
      final newGrid = _puzzle.grid.map((row) => List<int>.from(row)).toList();
      newGrid[_selectedRow!][_selectedCol!] = 0;

      // Effacer aussi les notes de cette cellule
      _puzzle = _puzzle.copyWith(grid: newGrid).clearNotes(_selectedRow!, _selectedCol!);
      _selectedNumber = null;
    });

    _feedbackService.numberRemoved();
    _saveGame();
  }

  /// Utilise un indice pour révéler une cellule
  void _useHint() {
    if (_hintsRemaining <= 0) {
      _feedbackService.errorOccurred();
      return;
    }
    if (_selectedRow == null || _selectedCol == null) {
      _feedbackService.errorOccurred();
      return;
    }
    if (_puzzle.isFixed[_selectedRow!][_selectedCol!]) {
      _feedbackService.errorOccurred();
      return;
    }
    if (_puzzle.grid[_selectedRow!][_selectedCol!] != 0) {
      _feedbackService.errorOccurred();
      return;
    }

    _saveMoveToHistory();

    setState(() {
      final newGrid = _puzzle.grid.map((row) => List<int>.from(row)).toList();
      final hintValue = _puzzle.solution[_selectedRow!][_selectedCol!];
      newGrid[_selectedRow!][_selectedCol!] = hintValue;

      // Nettoyer les notes de cette cellule et les notes invalides dans la région
      _puzzle = _puzzle.copyWith(grid: newGrid)
          .clearNotes(_selectedRow!, _selectedCol!)
          .clearInvalidNotes(_selectedRow!, _selectedCol!, hintValue);

      _selectedNumber = hintValue;
      _hintsRemaining--;
      _gameSession.hintsUsed++;
    });

    _feedbackService.hintUsed();
    _saveGame();

    // Vérifier si le jeu est terminé
    if (_puzzle.isComplete()) {
      _onGameCompleted();
    }
  }

  /// Affiche le dialogue des paramètres
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Animations'),
              subtitle: const Text('Activer les animations visuelles'),
              value: _enableAnimations,
              onChanged: (value) {
                setState(() {
                  _enableAnimations = value;
                });
                Navigator.of(context).pop();
                _showSettingsDialog(); // Réouvrir pour voir le changement
              },
            ),
            SwitchListTile(
              title: const Text('Sons'),
              subtitle: const Text('Activer les effets sonores'),
              value: _feedbackService.soundEnabled,
              onChanged: (value) async {
                await _feedbackService.setSoundEnabled(value);
                Navigator.of(context).pop();
                _showSettingsDialog(); // Réouvrir pour voir le changement
              },
            ),
            SwitchListTile(
              title: const Text('Vibrations'),
              subtitle: const Text('Activer le retour haptique'),
              value: _feedbackService.hapticEnabled,
              onChanged: (value) async {
                await _feedbackService.setHapticEnabled(value);
                Navigator.of(context).pop();
                _showSettingsDialog(); // Réouvrir pour voir le changement
              },
            ),
            const Divider(),
            const Text('Tester les effets:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  label: const Text('Succès'),
                  onPressed: () => _feedbackService.testFeedback(FeedbackType.success),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.error, color: Colors.red),
                  label: const Text('Erreur'),
                  onPressed: () => _feedbackService.testFeedback(FeedbackType.error),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > UIConstants.largeScreenBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.appTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
          _buildAppBarIndicators(isLargeScreen),
        ],
      ),
      body: Stack(
        children: [
          // Interface principale
          Container(
            decoration: BoxDecoration(
              gradient: _themeService.backgroundGradient,
            ),
            child: isLargeScreen
                ? _buildLargeScreenLayout()
                : _buildSmallScreenLayout(),
          ),

          // Particules de victoire
          if (_showVictoryParticles)
            Positioned.fill(
              child: ParticleEffects.victory(
                isActive: _showVictoryParticles,
                onComplete: () {
                  setState(() {
                    _showVictoryParticles = false;
                  });
                },
              ),
            ),

          // Popup de victoire
          if (_showVictoryPopup)
            Positioned.fill(
              child: AnimatedPopup(
                showPopup: _showVictoryPopup,
                animationType: PopupAnimationType.bounceScale,
                onDismissed: () {
                  setState(() {
                    _showVictoryPopup = false;
                  });
                },
                child: SudokuPopup.victory(
                  timeText: _formatTime(_elapsedSeconds),
                  scoreText: _gameSession.score.toString(),
                  onMenu: () {
                    setState(() {
                      _showVictoryPopup = false;
                    });
                    Navigator.of(context).pop();
                  },
                  onNewGame: () {
                    setState(() {
                      _showVictoryPopup = false;
                      _showVictoryParticles = false;
                      _gameCompleted = false;
                    });
                    _generateNewPuzzle();
                    _startTimer();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construit les indicateurs dans l'AppBar (timer et indices)
  Widget _buildAppBarIndicators(bool isLargeScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: _themeService.colors.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                size: UIConstants.hintIconSize,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Compteur d'indices
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: _hintsRemaining > 0
                ? AppColors.buttonHint
                : _themeService.colors.textSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb,
                size: UIConstants.hintIconSize,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$_hintsRemaining',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formate le temps en mm:ss ou hh:mm:ss
  String _formatTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Layout pour les grands écrans (tablette/desktop)
  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: UIConstants.gridMaxSize,
                maxHeight: UIConstants.gridMaxSize,
              ),
              margin: UIConstants.gridMargin,
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedSudokuGrid(
                  key: _gridKey,
                  puzzle: _puzzle,
                  selectedRow: _selectedRow,
                  selectedCol: _selectedCol,
                  selectedNumber: _selectedNumber,
                  onCellTap: _onCellTap,
                  enableAnimations: _enableAnimations,
                  gameCompleted: _gameCompleted,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButtons(
                  canUndo: _moveHistory.length > 1,
                  canClear: _selectedRow != null &&
                           _selectedCol != null &&
                           !_puzzle.isFixed[_selectedRow!][_selectedCol!],
                  canUseHint: _hintsRemaining > 0,
                  hintsRemaining: _hintsRemaining,
                  isNotesMode: _isNotesMode,
                  onUndo: _undoMove,
                  onClear: _clearCell,
                  onHint: _useHint,
                  onToggleNotes: () {
                    setState(() {
                      _isNotesMode = !_isNotesMode;
                    });
                    _feedbackService.buttonTapped();
                  },
                ),
                const SizedBox(height: UIConstants.controlsSpacing),
                NumberPad(
                  puzzle: _puzzle,
                  selectedNumber: _selectedNumber,
                  onNumberTap: _onNumberTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Layout pour les petits écrans (mobile)
  Widget _buildSmallScreenLayout() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: Container(
              margin: UIConstants.gridMargin,
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedSudokuGrid(
                  key: _gridKey,
                  puzzle: _puzzle,
                  selectedRow: _selectedRow,
                  selectedCol: _selectedCol,
                  selectedNumber: _selectedNumber,
                  onCellTap: _onCellTap,
                  enableAnimations: _enableAnimations,
                  gameCompleted: _gameCompleted,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionButtons(
                    canUndo: _moveHistory.length > 1,
                    canClear: _selectedRow != null &&
                             _selectedCol != null &&
                             !_puzzle.isFixed[_selectedRow!][_selectedCol!],
                    canUseHint: _hintsRemaining > 0,
                    hintsRemaining: _hintsRemaining,
                    isNotesMode: _isNotesMode,
                    onUndo: _undoMove,
                    onClear: _clearCell,
                    onHint: _useHint,
                    onToggleNotes: () {
                      setState(() {
                        _isNotesMode = !_isNotesMode;
                      });
                      _feedbackService.buttonTapped();
                    },
                  ),
                  const SizedBox(height: UIConstants.controlsSpacing),
                  NumberPad(
                    puzzle: _puzzle,
                    selectedNumber: _selectedNumber,
                    onNumberTap: _onNumberTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
