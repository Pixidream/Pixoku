import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget pour afficher les notes (petits chiffres) dans une cellule de Sudoku
class NotesCell extends StatelessWidget {
  final Set<int> notes;
  final bool isSelected;
  final bool isHighlighted;
  final bool isInSameRegion;
  final bool hasError;
  final bool isFixed;

  const NotesCell({
    super.key,
    required this.notes,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isInSameRegion = false,
    this.hasError = false,
    this.isFixed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const SizedBox.expand();
    }

    return Container(
      padding: const EdgeInsets.all(2),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          final hasNote = notes.contains(number);

          return Center(
            child: hasNote
                ? Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: _getNoteFontSize(context),
                      fontWeight: FontWeight.w500,
                      color: _getNoteColor(),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  /// Détermine la taille de police pour les notes selon l'écran
  double _getNoteFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > UIConstants.largeScreenBreakpoint;
    return isLargeScreen
        ? UIConstants.notesFontSize
        : UIConstants.notesFontSizeSmall;
  }

  /// Détermine la couleur des notes selon l'état de la cellule
  Color _getNoteColor() {
    if (hasError) {
      return AppColors.textError.withValues(alpha: 0.7);
    } else if (isHighlighted) {
      return AppColors.textHighlighted.withValues(alpha: 0.8);
    } else if (isInSameRegion) {
      return AppColors.textRegion.withValues(alpha: 0.7);
    } else if (isSelected) {
      return AppColors.textUser.withValues(alpha: 0.9);
    } else {
      return Colors.grey[600] ?? Colors.grey;
    }
  }
}

/// Widget pour une cellule hybride qui peut afficher soit une valeur soit des notes
class HybridCell extends StatelessWidget {
  final int value;
  final Set<int> notes;
  final bool isFixed;
  final bool isSelected;
  final bool isInSameRegion;
  final bool hasError;
  final bool isHighlighted;
  final VoidCallback onTap;

  const HybridCell({
    super.key,
    required this.value,
    required this.notes,
    required this.isFixed,
    required this.onTap,
    this.isSelected = false,
    this.isInSameRegion = false,
    this.hasError = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor, borderColor) = _getCellColors();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : null,
        ),
        child: value != 0
            ? Center(
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: UIConstants.cellFontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              )
            : NotesCell(
                notes: notes,
                isSelected: isSelected,
                isHighlighted: isHighlighted,
                isInSameRegion: isInSameRegion,
                hasError: hasError,
                isFixed: isFixed,
              ),
      ),
    );
  }

  /// Détermine les couleurs de la cellule selon son état
  (Color backgroundColor, Color textColor, Color? borderColor) _getCellColors() {
    if (isSelected) {
      return (
        AppColors.cellSelected,
        isFixed ? AppColors.textFixed : AppColors.textUser,
        Colors.blue[600],
      );
    } else if (hasError) {
      return (
        AppColors.cellError,
        AppColors.textError,
        null,
      );
    } else if (isHighlighted) {
      return (
        AppColors.cellHighlighted,
        AppColors.textHighlighted,
        null,
      );
    } else if (isInSameRegion) {
      return (
        AppColors.cellRegion,
        isFixed ? AppColors.textFixed : AppColors.textRegion,
        null,
      );
    } else {
      return (
        AppColors.gridBackground,
        isFixed ? AppColors.textFixed : AppColors.textUser,
        null,
      );
    }
  }
}

/// Widget pour afficher un aperçu des notes disponibles lors de la sélection
class NotesPreview extends StatelessWidget {
  final Set<int> availableNumbers;
  final Set<int> currentNotes;
  final Function(int) onNoteToggle;

  const NotesPreview({
    super.key,
    required this.availableNumbers,
    required this.currentNotes,
    required this.onNoteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tap pour ajouter/enlever une note',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final number = index + 1;
              final isAvailable = availableNumbers.contains(number);
              final hasNote = currentNotes.contains(number);

              return GestureDetector(
                onTap: isAvailable ? () => onNoteToggle(number) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: hasNote
                        ? Colors.blue[100]
                        : isAvailable
                            ? Colors.grey[100]
                            : Colors.grey[50],
                    border: Border.all(
                      color: hasNote
                          ? Colors.blue
                          : isAvailable
                              ? Colors.grey[400]!
                              : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: hasNote ? FontWeight.bold : FontWeight.normal,
                        color: hasNote
                            ? Colors.blue[800]
                            : isAvailable
                                ? Colors.black87
                                : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
