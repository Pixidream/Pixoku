import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Service responsable de la gestion des thèmes de l'application
class ThemeService extends ChangeNotifier {
  static ThemeService? _instance;
  static ThemeService get instance => _instance ??= ThemeService._();

  ThemeService._() {
    _loadTheme();
  }

  AppTheme _currentTheme = AppTheme.dark;
  bool _isLoading = true;

  /// Thème actuel
  AppTheme get currentTheme => _currentTheme;

  /// Couleurs du thème actuel
  AppThemeColors get colors => _currentTheme.colors;

  /// Indique si le service est en cours de chargement
  bool get isLoading => _isLoading;

  /// Charge le thème depuis les préférences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(GameConstants.themeKey);

      if (themeIndex != null && themeIndex < AppTheme.values.length) {
        _currentTheme = AppTheme.values[themeIndex];
      }
    } catch (e) {
      // En cas d'erreur, garder le thème par défaut (dark)
      _currentTheme = AppTheme.dark;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change le thème actuel
  Future<bool> setTheme(AppTheme theme) async {
    if (_currentTheme == theme) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(GameConstants.themeKey, theme.index);

      _currentTheme = theme;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Passe au thème suivant dans la liste
  Future<bool> nextTheme() async {
    final currentIndex = _currentTheme.index;
    final nextIndex = (currentIndex + 1) % AppTheme.values.length;
    return await setTheme(AppTheme.values[nextIndex]);
  }

  /// Passe au thème précédent dans la liste
  Future<bool> previousTheme() async {
    final currentIndex = _currentTheme.index;
    final previousIndex = currentIndex == 0
        ? AppTheme.values.length - 1
        : currentIndex - 1;
    return await setTheme(AppTheme.values[previousIndex]);
  }

  /// Obtient le ThemeData Flutter pour le thème actuel
  ThemeData get themeData {
    final themeColors = colors;

    return ThemeData(
      useMaterial3: true,
      brightness: _currentTheme == AppTheme.light ? Brightness.light : Brightness.dark,

      // Couleurs principales
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColors.primary,
        brightness: _currentTheme == AppTheme.light ? Brightness.light : Brightness.dark,
        primary: themeColors.primary,
        secondary: themeColors.accent,
        surface: themeColors.cardColor,
      ),

      // Couleur de fond globale
      scaffoldBackgroundColor: themeColors.backgroundTop,

      // Couleur des cartes
      cardColor: themeColors.cardColor,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: themeColors.textPrimary,
        titleTextStyle: TextStyle(
          color: themeColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Boutons de texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeColors.primary,
        ),
      ),

      // Couleurs de texte
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: themeColors.textPrimary),
        bodyMedium: TextStyle(color: themeColors.textPrimary),
        bodySmall: TextStyle(color: themeColors.textSecondary),
        headlineLarge: TextStyle(color: themeColors.textPrimary),
        headlineMedium: TextStyle(color: themeColors.textPrimary),
        headlineSmall: TextStyle(color: themeColors.textPrimary),
        titleLarge: TextStyle(color: themeColors.textPrimary),
        titleMedium: TextStyle(color: themeColors.textPrimary),
        titleSmall: TextStyle(color: themeColors.textSecondary),
        labelLarge: TextStyle(color: themeColors.textPrimary),
        labelMedium: TextStyle(color: themeColors.textSecondary),
        labelSmall: TextStyle(color: themeColors.textSecondary),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: themeColors.cardColor,
        titleTextStyle: TextStyle(
          color: themeColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: themeColors.textSecondary,
          fontSize: 16,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: themeColors.primary,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// Obtient un dégradé de fond pour le thème actuel
  LinearGradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.backgroundTop, colors.backgroundBottom],
    );
  }

  /// Vérifie si le thème actuel est sombre
  bool get isDarkTheme => _currentTheme != AppTheme.light;

  /// Obtient une couleur adaptée pour le texte sur un fond donné
  Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Obtient une couleur légèrement transparente de la couleur primaire
  Color get primaryWithOpacity => colors.primary.withValues(alpha: 0.1);

  /// Obtient une couleur d'accent légèrement transparente
  Color get accentWithOpacity => colors.accent.withValues(alpha: 0.1);

  /// Réinitialise le thème au thème par défaut
  Future<bool> resetTheme() async {
    return await setTheme(AppTheme.dark);
  }

  /// Obtient la liste de tous les thèmes disponibles
  List<AppTheme> get availableThemes => AppTheme.values;

  /// Vérifie si un thème spécifique est actuellement actif
  bool isThemeActive(AppTheme theme) => _currentTheme == theme;

  /// Obtient un aperçu des couleurs d'un thème (sans l'activer)
  AppThemeColors getThemeColors(AppTheme theme) => theme.colors;
}
