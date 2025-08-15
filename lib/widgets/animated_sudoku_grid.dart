import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../services/animation_service.dart';
import '../services/feedback_service.dart';
import '../utils/constants.dart';
import 'animated_sudoku_cell.dart';

/// Widget pour afficher la grille de Sudoku complète avec animations
class AnimatedSudokuGrid extends StatefulWidget {
  final SudokuPuzzle puzzle;
  final int? selectedRow;
  final int? selectedCol;
  final int? selectedNumber;
  final Function(int row, int col) onCellTap;
  final bool enableAnimations;
  final bool gameCompleted;

  const AnimatedSudokuGrid({
    super.key,
    required this.puzzle,
    required this.onCellTap,
    this.selectedRow,
    this.selectedCol,
    this.selectedNumber,
    this.enableAnimations = true,
    this.gameCompleted = false,
  });

  @override
  State<AnimatedSudokuGrid> createState() => AnimatedSudokuGridState();
}

class AnimatedSudokuGridState extends State<AnimatedSudokuGrid>
    with TickerProviderStateMixin {

  // Animation controllers pour la grille
  late AnimationController _gridEntryController;
  late AnimationController _completionController;
  late AnimationController _errorWaveController;

  // Animations pour la grille
  late Animation<double> _gridFadeAnimation;
  late Animation<Offset> _gridSlideAnimation;
  late Animation<double> _completionScaleAnimation;
  late Animation<double> _completionRotationAnimation;

  // Services
  final FeedbackService _feedbackService = FeedbackService();

  // Keys pour accéder aux cellules individuelles
  final List<List<GlobalKey<AnimatedSudokuCellState>>> _cellKeys = [];

  // State tracking
  bool _previousGameCompleted = false;
  List<List<int?>> _previousGrid = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCellKeys();
    _initializePreviousGrid();

    // Animation d'entrée de la grille
    if (widget.enableAnimations) {
      _gridEntryController.forward();
    }
  }

  void _initializeAnimations() {
    // Controllers
    _gridEntryController = AnimationService.createSlowController(this);
    _completionController = AnimationService.createCustomController(
      this,
      const Duration(milliseconds: 1000)
    );
    _errorWaveController = AnimationService.createDefaultController(this);

    // Animations
    _gridFadeAnimation = AnimationService.createFadeInAnimation(_gridEntryController);
    _gridSlideAnimation = AnimationService.createSlideUpAnimation(_gridEntryController);
    _completionScaleAnimation = AnimationService.createCompletionAnimation(_completionController);
    _completionRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeCellKeys() {
    _cellKeys.clear();
    for (int row = 0; row < GameConstants.gridSize; row++) {
      _cellKeys.add([]);
      for (int col = 0; col < GameConstants.gridSize; col++) {
        _cellKeys[row].add(GlobalKey<AnimatedSudokuCellState>());
      }
    }
  }

  void _initializePreviousGrid() {
    _previousGrid = List.generate(
      GameConstants.gridSize,
      (row) => List.generate(
        GameConstants.gridSize,
        (col) => widget.puzzle.grid[row][col] == 0 ? null : widget.puzzle.grid[row][col],
      ),
    );
    _previousGameCompleted = widget.gameCompleted;
  }

  @override
  void didUpdateWidget(AnimatedSudokuGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enableAnimations) return;

    // Check for game completion
    if (widget.gameCompleted != _previousGameCompleted) {
      if (widget.gameCompleted) {
        _playCompletionAnimation();
        _feedbackService.gameCompleted();
      }
      _previousGameCompleted = widget.gameCompleted;
    }

    // Check for grid changes and play appropriate animations
    _checkForGridChanges();
  }

  void _checkForGridChanges() {
    bool hasChanges = false;
    List<CellChange> changes = [];

    for (int row = 0; row < GameConstants.gridSize; row++) {
      for (int col = 0; col < GameConstants.gridSize; col++) {
        final currentValue = widget.puzzle.grid[row][col] == 0
            ? null
            : widget.puzzle.grid[row][col];
        final previousValue = _previousGrid[row][col];

        if (currentValue != previousValue) {
          hasChanges = true;
          changes.add(CellChange(
            row: row,
            col: col,
            previousValue: previousValue,
            newValue: currentValue,
          ));
        }
      }
    }

    if (hasChanges) {
      _handleGridChanges(changes);
      _updatePreviousGrid();
    }
  }

  void _handleGridChanges(List<CellChange> changes) {
    for (final change in changes) {
      final cellKey = _cellKeys[change.row][change.col];

      // Check if this change caused an error
      if (change.newValue != null) {
        final isValid = widget.puzzle.isValidMove(
          change.row,
          change.col,
          change.newValue!
        );

        if (!isValid) {
          // Play error animation on this cell
          cellKey.currentState?.playCustomAnimation(AnimationType.error);
        } else {
          // Play success animation
          cellKey.currentState?.playCustomAnimation(AnimationType.success);
        }
      }
    }
  }

  void _updatePreviousGrid() {
    for (int row = 0; row < GameConstants.gridSize; row++) {
      for (int col = 0; col < GameConstants.gridSize; col++) {
        _previousGrid[row][col] = widget.puzzle.grid[row][col] == 0
            ? null
            : widget.puzzle.grid[row][col];
      }
    }
  }

  Future<void> _playCompletionAnimation() async {
    // Play completion animation on the entire grid
    await _completionController.forward();

    // Play success animations on all cells in a wave pattern
    await _playSuccessWave();

    // Reset completion animation
    await _completionController.reverse();
  }

  Future<void> _playSuccessWave() async {
    // Start from center and expand outward
    const center = 4; // Middle of 9x9 grid
    const maxDistance = 6; // Maximum distance from center

    for (int distance = 0; distance <= maxDistance; distance++) {
      final futures = <Future<void>>[];

      for (int row = 0; row < GameConstants.gridSize; row++) {
        for (int col = 0; col < GameConstants.gridSize; col++) {
          final cellDistance = (row - center).abs() + (col - center).abs();

          if (cellDistance == distance) {
            final cellKey = _cellKeys[row][col];
            futures.add(
              Future.delayed(Duration(milliseconds: distance * 50), () {
                cellKey.currentState?.playCustomAnimation(AnimationType.success);
              })
            );
          }
        }
      }

      await Future.wait(futures);
    }
  }

  @override
  void dispose() {
    _gridEntryController.dispose();
    _completionController.dispose();
    _errorWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget grid = Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gridBorderThick, width: 3),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.gridBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(GameConstants.gridSize, (row) {
          return Expanded(
            child: Row(
              children: List.generate(GameConstants.gridSize, (col) {
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: col == 8
                            ? BorderSide.none
                            : col % GameConstants.blockSize == 2
                                ? const BorderSide(
                                    color: AppColors.gridBorderThick,
                                    width: 2,
                                  )
                                : const BorderSide(
                                    color: AppColors.gridBorderThin,
                                    width: 0.5,
                                  ),
                        bottom: row == 8
                            ? BorderSide.none
                            : row % GameConstants.blockSize == 2
                                ? const BorderSide(
                                    color: AppColors.gridBorderThick,
                                    width: 2,
                                  )
                                : const BorderSide(
                                    color: AppColors.gridBorderThin,
                                    width: 0.5,
                                  ),
                      ),
                    ),
                    child: AnimatedSudokuCell(
                      key: _cellKeys[row][col],
                      value: widget.puzzle.grid[row][col] == 0
                          ? null
                          : widget.puzzle.grid[row][col],
                      notes: widget.puzzle.getNotes(row, col).toList(),
                      isFixed: widget.puzzle.isFixed[row][col],
                      isSelected: widget.selectedRow == row && widget.selectedCol == col,
                      isInSameRegion: _isInSameRegion(row, col),
                      hasError: _hasError(row, col),
                      isHighlighted: _isHighlighted(row, col),
                      onTap: () => widget.onCellTap(row, col),
                      enableAnimations: widget.enableAnimations,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );

    if (!widget.enableAnimations) {
      return grid;
    }

    // Apply grid-level animations
    return AnimatedBuilder(
      animation: Listenable.merge([
        _gridFadeAnimation,
        _gridSlideAnimation,
        _completionScaleAnimation,
        _completionRotationAnimation,
      ]),
      child: grid,
      builder: (context, child) {
        Widget animatedGrid = child!;

        // Apply entry animations
        animatedGrid = SlideTransition(
          position: _gridSlideAnimation,
          child: FadeTransition(
            opacity: _gridFadeAnimation,
            child: animatedGrid,
          ),
        );

        // Apply completion animations
        if (_completionScaleAnimation.value > 0) {
          animatedGrid = Transform.scale(
            scale: 1.0 + (_completionScaleAnimation.value * 0.05),
            child: Transform.rotate(
              angle: _completionRotationAnimation.value,
              child: animatedGrid,
            ),
          );
        }

        return animatedGrid;
      },
    );
  }

  /// Vérifie si une cellule est dans la même région que la cellule sélectionnée
  bool _isInSameRegion(int row, int col) {
    if (widget.selectedRow == null || widget.selectedCol == null) return false;
    if (row == widget.selectedRow && col == widget.selectedCol) return false;

    return widget.puzzle.isInSameRegion(row, col, widget.selectedRow!, widget.selectedCol!);
  }

  /// Vérifie si une cellule a une erreur de placement
  bool _hasError(int row, int col) {
    final value = widget.puzzle.grid[row][col];
    return value != 0 && !widget.puzzle.isValidMove(row, col, value);
  }

  /// Vérifie si une cellule doit être mise en surbrillance (même nombre)
  bool _isHighlighted(int row, int col) {
    if (widget.selectedNumber == null) return false;
    if (widget.selectedRow == row && widget.selectedCol == col) return false;

    return widget.puzzle.grid[row][col] == widget.selectedNumber &&
           widget.puzzle.grid[row][col] != 0;
  }

  // Public methods to trigger animations
  void playErrorWave() {
    if (widget.enableAnimations) {
      _errorWaveController.forward().then((_) {
        _errorWaveController.reset();
      });
    }
  }

  void highlightNumber(int number) {
    if (!widget.enableAnimations) return;

    for (int row = 0; row < GameConstants.gridSize; row++) {
      for (int col = 0; col < GameConstants.gridSize; col++) {
        if (widget.puzzle.grid[row][col] == number) {
          _cellKeys[row][col].currentState?.playCustomAnimation(AnimationType.highlight);
        }
      }
    }
  }

  void unhighlightAll() {
    if (!widget.enableAnimations) return;

    for (int row = 0; row < GameConstants.gridSize; row++) {
      for (int col = 0; col < GameConstants.gridSize; col++) {
        _cellKeys[row][col].currentState?.playCustomAnimation(AnimationType.unhighlight);
      }
    }
  }
}

// Helper class for tracking cell changes
class CellChange {
  final int row;
  final int col;
  final int? previousValue;
  final int? newValue;

  CellChange({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.newValue,
  });
}

// Extension to access animation methods
extension AnimatedSudokuGridExtension on GlobalKey<AnimatedSudokuGridState> {
  void playErrorWave() {
    currentState?.playErrorWave();
  }

  void highlightNumber(int number) {
    currentState?.highlightNumber(number);
  }

  void unhighlightAll() {
    currentState?.unhighlightAll();
  }
}
