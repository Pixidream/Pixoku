import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget pour les boutons d'action (Annuler, Effacer, Notes, Indice)
class ActionButtons extends StatelessWidget {
  final bool canUndo;
  final bool canClear;
  final bool canUseHint;
  final bool isNotesMode;
  final int hintsRemaining;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;
  final VoidCallback? onHint;
  final VoidCallback? onToggleNotes;

  const ActionButtons({
    super.key,
    required this.canUndo,
    required this.canClear,
    required this.canUseHint,
    required this.isNotesMode,
    required this.hintsRemaining,
    this.onUndo,
    this.onClear,
    this.onHint,
    this.onToggleNotes,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > UIConstants.largeScreenBreakpoint;

    return Container(
      padding: UIConstants.controlsPadding,
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              icon: Icons.undo,
              label: AppTexts.undo,
              isEnabled: canUndo,
              backgroundColor: AppColors.buttonUndo,
              onPressed: onUndo,
              isLargeScreen: isLargeScreen,
            ),
          ),
          const SizedBox(width: UIConstants.buttonSpacing),
          Expanded(
            child: ActionButton(
              icon: Icons.clear,
              label: AppTexts.clear,
              isEnabled: canClear,
              backgroundColor: AppColors.buttonClear,
              onPressed: onClear,
              isLargeScreen: isLargeScreen,
            ),
          ),
          const SizedBox(width: UIConstants.buttonSpacing),
          Expanded(
            child: ActionButton(
              icon: Icons.edit_note,
              label: 'Notes',
              isEnabled: true,
              backgroundColor: isNotesMode ? Colors.green : Colors.grey[600]!,
              onPressed: onToggleNotes,
              isLargeScreen: isLargeScreen,
            ),
          ),
          const SizedBox(width: UIConstants.buttonSpacing),
          Expanded(
            child: ActionButton(
              icon: Icons.lightbulb,
              label: AppTexts.hint,
              isEnabled: canUseHint,
              backgroundColor: AppColors.buttonHint,
              onPressed: onHint,
              isLargeScreen: isLargeScreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour un bouton d'action individuel
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final bool isLargeScreen;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.backgroundColor,
    this.onPressed,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(
        icon,
        size: isLargeScreen
            ? UIConstants.controlIconSizeLarge
            : UIConstants.controlIconSizeSmall,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isLargeScreen
              ? UIConstants.controlButtonFontSizeLarge
              : UIConstants.controlButtonFontSizeSmall,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? backgroundColor : Colors.grey,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 8 : 6,
        ),
      ),
    );
  }
}
