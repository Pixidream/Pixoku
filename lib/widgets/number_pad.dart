import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../utils/constants.dart';

/// Widget pour le pavé numérique permettant de sélectionner les chiffres
class NumberPad extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final int? selectedNumber;
  final Function(int number) onNumberTap;

  const NumberPad({
    super.key,
    required this.puzzle,
    required this.onNumberTap,
    this.selectedNumber,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > UIConstants.largeScreenBreakpoint;

    return Container(
      padding: UIConstants.controlsPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(GameConstants.gridSize, (index) {
          final number = index + 1;
          final isSelected = selectedNumber == number;
          final numberCount = puzzle.getNumberCount(number);
          final isDisabled = numberCount >= GameConstants.totalCellsPerNumber;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: UIConstants.numberButtonSpacing),
              height: isLargeScreen
                  ? UIConstants.numberButtonHeightLarge
                  : UIConstants.numberButtonHeightSmall,
              child: NumberButton(
                number: number,
                isSelected: isSelected,
                isDisabled: isDisabled,
                isLargeScreen: isLargeScreen,
                onTap: () => onNumberTap(number),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Widget pour un bouton individuel du pavé numérique
class NumberButton extends StatelessWidget {
  final int number;
  final bool isSelected;
  final bool isDisabled;
  final bool isLargeScreen;
  final VoidCallback onTap;

  const NumberButton({
    super.key,
    required this.number,
    required this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getForegroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            number.toString(),
            style: TextStyle(
              fontSize: isLargeScreen
                  ? UIConstants.numberButtonFontSizeLarge
                  : UIConstants.numberButtonFontSizeSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isDisabled)
            Icon(
              Icons.check,
              size: isLargeScreen
                  ? UIConstants.checkIconSizeLarge
                  : UIConstants.checkIconSizeSmall,
              color: AppColors.buttonDisabledText,
            ),
        ],
      ),
    );
  }

  /// Détermine la couleur de fond du bouton selon son état
  Color _getBackgroundColor() {
    if (isDisabled) {
      return AppColors.buttonDisabled;
    } else if (isSelected) {
      return AppColors.buttonSelected;
    } else {
      return AppColors.buttonNormal;
    }
  }

  /// Détermine la couleur du texte du bouton selon son état
  Color _getForegroundColor() {
    if (isDisabled) {
      return AppColors.buttonDisabledText;
    } else {
      return Colors.white;
    }
  }
}
