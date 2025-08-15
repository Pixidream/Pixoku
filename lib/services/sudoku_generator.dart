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

  /// Retire aléatoirement des cellules de la grille complète avec distribution équilibrée
  void _removeCells(List<List<int>> grid, int cellsToRemove) {
    // Minimum d'indices à garder par bloc selon la difficulté
    int minIndicesPerBlock = _getMinIndicesPerBlock(cellsToRemove);
    const int totalBlocks = 9;

    // Calculer le nombre maximum de cellules à retirer par bloc
    int cellsPerBlock = 9; // Chaque bloc a 9 cellules
    int maxRemovablePerBlock = cellsPerBlock - minIndicesPerBlock;

    // Si on doit retirer plus que le maximum possible, ajuster
    if (cellsToRemove > maxRemovablePerBlock * totalBlocks) {
      cellsToRemove = maxRemovablePerBlock * totalBlocks;
    }

    // Créer une liste pour tracker combien de cellules ont été retirées de chaque bloc
    List<List<int>> blockRemovals = List.generate(3, (_) => List.filled(3, 0));

    // Distribuer équitablement les retraits entre les blocs
    int baseRemovalsPerBlock = cellsToRemove ~/ totalBlocks;
    int extraRemovals = cellsToRemove % totalBlocks;

    // Créer une liste de toutes les positions, organisées par bloc
    Map<String, List<List<int>>> blockPositions = {};

    for (int blockRow = 0; blockRow < 3; blockRow++) {
      for (int blockCol = 0; blockCol < 3; blockCol++) {
        String key = '$blockRow,$blockCol';
        blockPositions[key] = [];

        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int row = blockRow * 3 + i;
            int col = blockCol * 3 + j;
            blockPositions[key]!.add([row, col]);
          }
        }

        // Mélanger les positions dans chaque bloc
        blockPositions[key]!.shuffle(_random);
      }
    }

    // Retirer les cellules bloc par bloc
    int totalRemoved = 0;
    List<String> blockKeys = blockPositions.keys.toList()..shuffle(_random);

    for (String key in blockKeys) {
      int blockRow = int.parse(key.split(',')[0]);
      int blockCol = int.parse(key.split(',')[1]);

      // Calculer combien retirer de ce bloc
      int toRemoveFromBlock = baseRemovalsPerBlock;
      if (extraRemovals > 0) {
        toRemoveFromBlock++;
        extraRemovals--;
      }

      // S'assurer de ne pas dépasser le maximum pour ce bloc
      toRemoveFromBlock = toRemoveFromBlock.clamp(0, maxRemovablePerBlock);

      // Retirer les cellules de ce bloc
      List<List<int>> positions = blockPositions[key]!;
      for (int i = 0; i < toRemoveFromBlock && i < positions.length; i++) {
        int row = positions[i][0];
        int col = positions[i][1];
        grid[row][col] = 0;
        blockRemovals[blockRow][blockCol]++;
        totalRemoved++;

        if (totalRemoved >= cellsToRemove) {
          return;
        }
      }
    }

    // Si on n'a pas retiré assez (ce qui ne devrait pas arriver),
    // retirer aléatoirement les cellules restantes en respectant les minimums
    while (totalRemoved < cellsToRemove) {
      bool removed = false;

      for (String key in blockKeys) {
        int blockRow = int.parse(key.split(',')[0]);
        int blockCol = int.parse(key.split(',')[1]);

        // Vérifier si on peut encore retirer de ce bloc
        if (blockRemovals[blockRow][blockCol] < maxRemovablePerBlock) {
          List<List<int>> positions = blockPositions[key]!;

          // Trouver une cellule non vide dans ce bloc
          for (List<int> pos in positions) {
            if (grid[pos[0]][pos[1]] != 0) {
              grid[pos[0]][pos[1]] = 0;
              blockRemovals[blockRow][blockCol]++;
              totalRemoved++;
              removed = true;
              break;
            }
          }
        }

        if (removed || totalRemoved >= cellsToRemove) {
          break;
        }
      }

      // Sécurité pour éviter une boucle infinie
      if (!removed) {
        break;
      }
    }

    // Vérifier la distribution finale
    if (!_validateDistribution(grid, minIndicesPerBlock)) {
      // Si la distribution n'est pas bonne, réessayer avec une nouvelle grille
      _removeCells(grid, cellsToRemove);
    }
  }

  /// Détermine le nombre minimum d'indices par bloc selon la difficulté
  int _getMinIndicesPerBlock(int cellsToRemove) {
    // Plus on retire de cellules, plus la difficulté est élevée
    if (cellsToRemove <= 40) {
      // Facile : au moins 3-4 indices par bloc
      return 3;
    } else if (cellsToRemove <= 50) {
      // Moyen : au moins 2-3 indices par bloc
      return 2;
    } else {
      // Difficile : au moins 2 indices par bloc
      return 2;
    }
  }

  /// Valide que la distribution des indices est acceptable
  bool _validateDistribution(List<List<int>> grid, int minIndicesPerBlock) {
    // Vérifier chaque bloc 3x3
    for (int blockRow = 0; blockRow < 3; blockRow++) {
      for (int blockCol = 0; blockCol < 3; blockCol++) {
        int count = 0;

        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int row = blockRow * 3 + i;
            int col = blockCol * 3 + j;
            if (grid[row][col] != 0) {
              count++;
            }
          }
        }

        // Si un bloc a moins d'indices que le minimum requis
        if (count < minIndicesPerBlock) {
          return false;
        }
      }
    }

    // Vérifier aussi que chaque ligne et colonne a au moins 2 indices
    for (int i = 0; i < GameConstants.gridSize; i++) {
      int rowCount = 0;
      int colCount = 0;

      for (int j = 0; j < GameConstants.gridSize; j++) {
        if (grid[i][j] != 0) rowCount++;
        if (grid[j][i] != 0) colCount++;
      }

      if (rowCount < 2 || colCount < 2) {
        return false;
      }
    }

    return true;
  }
}
