import 'package:flutter/material.dart';

/// Énumération des niveaux de difficulté du Sudoku
enum Difficulty {
  facile,
  moyen,
  difficile
}

/// Extension pour obtenir les propriétés des difficultés
extension DifficultyExtension on Difficulty {
  /// Couleur associée à la difficulté
  Color get color {
    switch (this) {
      case Difficulty.facile:
        return Colors.green;
      case Difficulty.moyen:
        return Colors.orange;
      case Difficulty.difficile:
        return Colors.red;
    }
  }

  /// Nom d'affichage de la difficulté
  String get displayName {
    switch (this) {
      case Difficulty.facile:
        return 'FACILE';
      case Difficulty.moyen:
        return 'MOYEN';
      case Difficulty.difficile:
        return 'DIFFICILE';
    }
  }

  /// Nombre de cellules à retirer selon la difficulté
  /// Ajusté pour garantir une distribution équilibrée (min 2-3 indices par bloc)
  int get cellsToRemove {
    switch (this) {
      case Difficulty.facile:
        return 36;  // ~45 indices restants, 5 par bloc en moyenne
      case Difficulty.moyen:
        return 46;  // ~35 indices restants, 3-4 par bloc en moyenne
      case Difficulty.difficile:
        return 54;  // ~27 indices restants, 3 par bloc en moyenne
    }
  }
}

/// Constantes de gameplay
class GameConstants {
  static const int gridSize = 9;
  static const int blockSize = 3;
  static const int initialHints = 3;
  static const int maxMoveHistory = 20;
  static const int totalCellsPerNumber = 9;

  // Timer et scoring
  static const int timerUpdateIntervalMs = 1000;
  static const int maxNotesPerCell = 9;

  // Sauvegarde
  static const String gameStatsKey = 'sudoku_stats';
  static const String playerStatsKey = 'sudoku_player_stats';
  static const String themeKey = 'sudoku_theme';
  static const int maxGameHistory = 100;
}

/// Constantes d'interface utilisateur
class UIConstants {
  // Tailles
  static const double menuCardWidth = 350.0;
  static const double gridMaxSize = 600.0;
  static const double largeScreenBreakpoint = 600.0;

  // Espacements
  static const EdgeInsets gridMargin = EdgeInsets.all(16.0);
  static const EdgeInsets controlsPadding = EdgeInsets.symmetric(horizontal: 8.0);
  static const double controlsSpacing = 16.0;
  static const double buttonSpacing = 6.0;
  static const double numberButtonSpacing = 2.0;

  // Tailles de boutons
  static const double numberButtonHeightLarge = 48.0;
  static const double numberButtonHeightSmall = 40.0;

  // Tailles de police
  static const double cellFontSize = 24.0;
  static const double numberButtonFontSizeLarge = 18.0;
  static const double numberButtonFontSizeSmall = 16.0;
  static const double controlButtonFontSizeLarge = 12.0;
  static const double controlButtonFontSizeSmall = 10.0;

  // Tailles d'icônes
  static const double hintIconSize = 16.0;
  static const double controlIconSizeLarge = 16.0;
  static const double controlIconSizeSmall = 14.0;
  static const double checkIconSizeLarge = 14.0;
  static const double checkIconSizeSmall = 12.0;

  // Timer
  static const double timerFontSize = 24.0;
  static const double timerFontSizeSmall = 20.0;

  // Notes mode
  static const double notesFontSize = 8.0;
  static const double notesFontSizeSmall = 6.0;

  // Stats et scoreboard
  static const double scoreFontSize = 18.0;
  static const double statsFontSize = 14.0;
  static const double recordFontSize = 12.0;

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration winAnimationDuration = Duration(milliseconds: 1000);
}

/// Constantes de couleurs
class AppColors {
  // Couleurs de dégradé de fond
  static const Color backgroundTop = Color(0xFF1A1B2E);
  static const Color backgroundBottom = Color(0xFF2D3748);
  static const Color cardColor = Color(0xFF2D3748);

  // Couleurs de la grille
  static const Color gridBackground = Colors.white;
  static const Color gridBorderThick = Color(0xFF757575); // Colors.grey[600]
  static const Color gridBorderThin = Color(0xFFE0E0E0);  // Colors.grey[300]

  // Couleurs des cellules
  static const Color cellSelected = Color.fromRGBO(59, 130, 246, 0.3);
  static const Color cellError = Color.fromRGBO(239, 68, 68, 0.25);
  static const Color cellHighlighted = Color.fromRGBO(34, 197, 94, 0.15);
  static const Color cellRegion = Color.fromRGBO(156, 163, 175, 0.1);

  // Couleurs de fond des cellules pour les animations
  static const Color selectedCellBackground = Color.fromRGBO(59, 130, 246, 0.2);
  static const Color errorCellBackground = Color.fromRGBO(239, 68, 68, 0.15);
  static const Color highlightedCellBackground = Color.fromRGBO(34, 197, 94, 0.1);
  static const Color sameRegionBackground = Color.fromRGBO(156, 163, 175, 0.08);
  static const Color fixedCellBackground = Color.fromRGBO(245, 245, 245, 1.0);
  static const Color emptyCellBackground = Colors.white;

  // Couleurs de bordure des cellules
  static const Color selectedCellBorder = Color(0xFF1976D2);

  // Couleurs de texte
  static const Color textFixed = Color(0xFF212121);     // Colors.black87
  static const Color textUser = Color(0xFF1976D2);      // Colors.blue[800]
  static const Color textError = Color(0xFFC62828);     // Colors.red[800]
  static const Color textHighlighted = Color(0xFF2E7D32); // Colors.green[800]
  static const Color textRegion = Color(0xFF1976D2);    // Colors.blue[700]
  static const Color textLight = Color(0xFFE0E0E0);     // Colors.grey[300]

  // Couleurs de texte pour les cellules animées
  static const Color fixedText = Color(0xFF212121);
  static const Color userText = Color(0xFF1976D2);
  static const Color errorText = Color(0xFFC62828);
  static const Color notesText = Color(0xFF666666);

  // Couleurs des boutons
  static const Color buttonSelected = Color(0xFF1976D2);    // Colors.blue[600]
  static const Color buttonNormal = Color(0xFF757575);      // Colors.grey[600]
  static const Color buttonDisabled = Color(0xFFBDBDBD);    // Colors.grey[400]
  static const Color buttonDisabledText = Color(0xFF757575); // Colors.grey[600]
  static const Color buttonHint = Colors.orange;
  static const Color buttonUndo = Color(0xFF1976D2);        // Colors.blue[600]
  static const Color buttonClear = Color(0xFF757575);       // Colors.grey[600]
  static const Color buttonNewGame = Colors.red;
}

/// Énumération des thèmes disponibles
enum AppTheme {
  dark,
  light,
  blue,
  green,
  purple,
  orange
}

/// Extension pour les propriétés des thèmes
extension AppThemeExtension on AppTheme {
  String get displayName {
    switch (this) {
      case AppTheme.dark:
        return AppTexts.darkTheme;
      case AppTheme.light:
        return AppTexts.lightTheme;
      case AppTheme.blue:
        return AppTexts.blueTheme;
      case AppTheme.green:
        return AppTexts.greenTheme;
      case AppTheme.purple:
        return AppTexts.purpleTheme;
      case AppTheme.orange:
        return AppTexts.orangeTheme;
    }
  }

  /// Couleurs du thème
  AppThemeColors get colors {
    switch (this) {
      case AppTheme.dark:
        return AppThemeColors.dark;
      case AppTheme.light:
        return AppThemeColors.light;
      case AppTheme.blue:
        return AppThemeColors.blue;
      case AppTheme.green:
        return AppThemeColors.green;
      case AppTheme.purple:
        return AppThemeColors.purple;
      case AppTheme.orange:
        return AppThemeColors.orange;
    }
  }
}

/// Couleurs par thème
class AppThemeColors {
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color cardColor;
  final Color primary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  const AppThemeColors({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.cardColor,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const AppThemeColors dark = AppThemeColors(
    backgroundTop: Color(0xFF1A1B2E),
    backgroundBottom: Color(0xFF2D3748),
    cardColor: Color(0xFF2D3748),
    primary: Color(0xFF4A90E2),
    accent: Color(0xFF7ED321),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFE0E0E0),
  );

  static const AppThemeColors light = AppThemeColors(
    backgroundTop: Color(0xFFF5F7FA),
    backgroundBottom: Color(0xFFE8EEF0),
    cardColor: Colors.white,
    primary: Color(0xFF2196F3),
    accent: Color(0xFF4CAF50),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
  );

  static const AppThemeColors blue = AppThemeColors(
    backgroundTop: Color(0xFF0D47A1),
    backgroundBottom: Color(0xFF1976D2),
    cardColor: Color(0xFF1E88E5),
    primary: Color(0xFF2196F3),
    accent: Color(0xFF03DAC6),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFE3F2FD),
  );

  static const AppThemeColors green = AppThemeColors(
    backgroundTop: Color(0xFF1B5E20),
    backgroundBottom: Color(0xFF388E3C),
    cardColor: Color(0xFF4CAF50),
    primary: Color(0xFF66BB6A),
    accent: Color(0xFFFF9800),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFE8F5E8),
  );

  static const AppThemeColors purple = AppThemeColors(
    backgroundTop: Color(0xFF4A148C),
    backgroundBottom: Color(0xFF7B1FA2),
    cardColor: Color(0xFF9C27B0),
    primary: Color(0xFFBA68C8),
    accent: Color(0xFFE91E63),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFF3E5F5),
  );

  static const AppThemeColors orange = AppThemeColors(
    backgroundTop: Color(0xFFE65100),
    backgroundBottom: Color(0xFFFF9800),
    cardColor: Color(0xFFFFB74D),
    primary: Color(0xFFFF9800),
    accent: Color(0xFF8BC34A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFFFF3E0),
  );
}

/// Constantes pour les animations et feedback
class AnimationConstants {
  static const Duration fadeIn = Duration(milliseconds: 150);
  static const Duration fadeOut = Duration(milliseconds: 100);
  static const Duration slideIn = Duration(milliseconds: 200);
  static const Duration bounce = Duration(milliseconds: 300);
  static const Duration pulse = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
}

/// Constantes pour le feedback haptique
class FeedbackConstants {
  static const bool enableVibration = true;
  static const bool enableSound = false; // Désactivé par défaut
  static const Duration lightVibration = Duration(milliseconds: 50);
  static const Duration mediumVibration = Duration(milliseconds: 100);
  static const Duration heavyVibration = Duration(milliseconds: 150);
}

/// Messages et textes de l'application
class AppTexts {
  // Titre de l'application
  static const String appTitle = 'SUDOKU';

  // Menu
  static const String chooseLevel = 'Choisissez votre niveau';
  static const String continueGame = 'Continuer';
  static const String noSavedGame = 'Aucune partie sauvegardée';

  // Dialog de nouvelle partie
  static const String gameInProgressTitle = 'Partie en cours';
  static const String gameInProgressMessage =
      'Une partie sauvegardée existe. Voulez-vous vraiment commencer une nouvelle partie ? '
      'La progression actuelle sera perdue.';
  static const String cancel = 'Annuler';
  static const String newGame = 'Nouvelle partie';

  // Dialog de victoire
  static const String congratulationsTitle = 'Félicitations!';
  static const String congratulationsMessage = 'Vous avez résolu le Sudoku!';
  static const String menu = 'Menu';

  // Boutons de contrôle
  static const String placeNumber = 'Placer chiffre';
  static const String undo = 'Annuler';
  static const String clear = 'Effacer';
  static const String hint = 'Indice';

  // Clés de sauvegarde
  static const String saveKey = 'sudoku_save';

  // Timer
  static const String time = 'Temps';
  static const String score = 'Score';
  static const String bestTime = 'Meilleur temps';
  static const String averageTime = 'Temps moyen';

  // Notes
  static const String notesMode = 'Mode notes';
  static const String toggleNotes = 'Notes ON/OFF';

  // Stats et scoreboard
  static const String statistics = 'Statistiques';
  static const String scoreboard = 'Classement';
  static const String totalGames = 'Parties jouées';
  static const String completionRate = 'Taux de réussite';
  static const String totalScore = 'Score total';
  static const String gamesCompleted = 'Parties terminées';
  static const String hintsUsed = 'Indices utilisés';
  static const String errors = 'Erreurs';
  static const String noGamesPlayed = 'Aucune partie jouée';
  static const String recentGames = 'Parties récentes';

  // Thèmes
  static const String themes = 'Thèmes';
  static const String lightTheme = 'Clair';
  static const String darkTheme = 'Sombre';
  static const String blueTheme = 'Bleu';
  static const String greenTheme = 'Vert';
  static const String purpleTheme = 'Violet';
  static const String orangeTheme = 'Orange';
}
