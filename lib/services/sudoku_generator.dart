import 'dart:math';
import '../models/sudoku_puzzle.dart';
import '../utils/constants.dart';

/// Service responsable de la génération des puzzles de Sudoku
class SudokuGenerator {
  final Random _random = Random();

  /// Génère un nouveau puzzle selon la difficulté spécifiée
  SudokuPuzzle generatePuzzle(Difficulty difficulty) {
    // Générer une grille complète
    List<List<int>> solution = _generateCompleteGrid();

    // Créer une copie pour le puzzle
    List<List<int>> puzzle = solution.map((row) => List<int>.from(row)).toList();
    List<List<bool>> isFixed = List.generate(
      GameConstants.gridSize,
      (i) => List.generate(GameConstants.gridSize, (j) => false)
    );

    // Retirer des cellules selon la difficulté
    _removeCells(puzzle, difficulty.cellsToRemove);

    // Marquer les cellules restantes comme fixes
    for (int i = 0; i < GameConstants.gridSize; i++) {
      for (int j = 0; j < GameConstants.gridSize; j++) {
        isFixed[i][j] = puzzle[i][j] != 0;
      }
    }

    return SudokuPuzzle.withEmptyNotes(
      puzzle,
      solution,
      isFixed,
    );
  }

  /// Génère une grille de Sudoku complètement remplie
  List<List<int>> _generateCompleteGrid() {
    List<List<int>> grid = List.generate(
      GameConstants.gridSize,
      (i) => List.generate(GameConstants.gridSize, (j) => 0)
    );

    _fillGrid(grid);
    return grid;
  }

  /// Remplit récursivement la grille avec des valeurs valides
  bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < GameConstants.gridSize; row++) {
      for (int col = 0; col < GameConstants.gridSize; col++) {
        if (grid[row][col] == 0) {
          // Générer une liste de nombres mélangée pour plus de variété
          List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

          for (int num in numbers) {
            if (_isValidPlacement(grid, row, col, num)) {
              grid[row][col] = num;

              if (_fillGrid(grid)) {
                return true;
              }

              // Backtrack
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Vérifie si un nombre peut être placé à une position donnée
  bool _isValidPlacement(List<List<int>> grid, int row, int col, int num) {
    // Vérifier la ligne et la colonne
    for (int x = 0; x < GameConstants.gridSize; x++) {
      if (grid[row][x] == num || grid[x][col] == num) {
        return false;
      }
    }

    // Vérifier le bloc 3x3
    int startRow = row - row % GameConstants.blockSize;
    int startCol = col - col % GameConstants.blockSize;

    for (int i = 0; i < GameConstants.blockSize; i++) {
      for (int j = 0; j < GameConstants.blockSize; j++) {
        if (grid[i + startRow][j + startCol] == num) {
          return false;
        }
      }
    }

    return true;
  }

  /// Retire aléatoirement des cellules de la grille complète
  void _removeCells(List<List<int>> grid, int cellsToRemove) {
    // Créer une liste de toutes les positions possibles
    List<int> positions = List.generate(
      GameConstants.gridSize * GameConstants.gridSize,
      (i) => i
    );

    // Mélanger les positions pour un retrait aléatoire
    positions.shuffle(_random);

    // Retirer les cellules demandées
    for (int i = 0; i < cellsToRemove && i < positions.length; i++) {
      int pos = positions[i];
      int row = pos ~/ GameConstants.gridSize;
      int col = pos % GameConstants.gridSize;
      grid[row][col] = 0;
    }
  }
}
