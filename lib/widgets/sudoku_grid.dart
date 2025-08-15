import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../utils/constants.dart';
import 'notes_cell.dart';

/// Widget pour afficher la grille de Sudoku complète
class SudokuGrid extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final int? selectedRow;
  final int? selectedCol;
  final int? selectedNumber;
  final Function(int row, int col) onCellTap;

  const SudokuGrid({
    super.key,
    required this.puzzle,
    required this.onCellTap,
    this.selectedRow,
    this.selectedCol,
    this.selectedNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    child: HybridCell(
                      value: puzzle.grid[row][col],
                      notes: puzzle.getNotes(row, col),
                      isFixed: puzzle.isFixed[row][col],
                      isSelected: selectedRow == row && selectedCol == col,
                      isInSameRegion: _isInSameRegion(row, col),
                      hasError: _hasError(row, col),
                      isHighlighted: _isHighlighted(row, col),
                      onTap: () => onCellTap(row, col),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  /// Vérifie si une cellule est dans la même région que la cellule sélectionnée
  bool _isInSameRegion(int row, int col) {
    if (selectedRow == null || selectedCol == null) return false;
    if (row == selectedRow && col == selectedCol) return false;

    return puzzle.isInSameRegion(row, col, selectedRow!, selectedCol!);
  }

  /// Vérifie si une cellule a une erreur de placement
  bool _hasError(int row, int col) {
    final value = puzzle.grid[row][col];
    return value != 0 && !puzzle.isValidMove(row, col, value);
  }

  /// Vérifie si une cellule doit être mise en surbrillance (même nombre)
  bool _isHighlighted(int row, int col) {
    if (selectedNumber == null) return false;
    if (selectedRow == row && selectedCol == col) return false;

    return puzzle.grid[row][col] == selectedNumber && puzzle.grid[row][col] != 0;
  }
}
