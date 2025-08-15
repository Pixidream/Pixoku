import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../utils/constants.dart';

/// Widget pour sélectionner et prévisualiser les thèmes
class ThemeSelector extends StatefulWidget {
  const ThemeSelector({super.key});

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  final ThemeService _themeService = ThemeService.instance;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisissez votre thème',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personnalisez l\'apparence de votre jeu Sudoku',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 400 ? 2 : 1;
              final childAspectRatio = constraints.maxWidth > 400 ? 1.2 : 1.8;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: AppTheme.values.length,
                itemBuilder: (context, index) {
                  final theme = AppTheme.values[index];
                  final isSelected = _themeService.currentTheme == theme;

                  return _buildThemeCard(theme, isSelected);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// Construit une carte de thème avec prévisualisation
  Widget _buildThemeCard(AppTheme theme, bool isSelected) {
    final themeColors = theme.colors;

    return GestureDetector(
      onTap: () => _selectTheme(theme),
      child: AnimatedContainer(
        duration: AnimationConstants.fadeIn,
        curve: AnimationConstants.defaultCurve,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeColors.primary : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? themeColors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // En-tête avec dégradé
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [themeColors.backgroundTop, themeColors.backgroundBottom],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Simulation d'une mini grille
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: themeColors.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: themeColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: index == 4
                                      ? themeColors.primary.withValues(alpha: 0.3)
                                      : themeColors.cardColor,
                                  border: Border.all(
                                    color: themeColors.primary.withValues(alpha: 0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: index == 4
                                    ? Center(
                                        child: Text(
                                          '5',
                                          style: TextStyle(
                                            color: themeColors.primary,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),

                      // Indicateur de sélection
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: themeColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Informations du thème
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  color: themeColors.cardColor,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          theme.displayName,
                          style: TextStyle(
                            color: themeColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Palette de couleurs
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildColorDot(themeColors.primary, 8),
                              const SizedBox(width: 2),
                              _buildColorDot(themeColors.accent, 8),
                              const SizedBox(width: 2),
                              _buildColorDot(themeColors.backgroundTop, 8),
                            ],
                          ),

                          // Badge du type de thème
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              theme == AppTheme.light ? 'Clair' : 'Sombre',
                              style: TextStyle(
                                color: themeColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un petit point coloré
  Widget _buildColorDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
    );
  }

  /// Construit les actions rapides
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 300) {
                  // Mode vertical pour très petits écrans
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _themeService.previousTheme,
                          icon: const Icon(Icons.skip_previous, size: 18),
                          label: const Text('Précédent'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _themeService.nextTheme,
                          icon: const Icon(Icons.skip_next, size: 18),
                          label: const Text('Suivant'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Mode horizontal pour écrans normaux
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _themeService.previousTheme,
                        icon: const Icon(Icons.skip_previous, size: 18),
                        label: const Text('Précédent'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _themeService.nextTheme,
                        icon: const Icon(Icons.skip_next, size: 18),
                        label: const Text('Suivant'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetToDefault,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réinitialiser'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sélectionne un thème
  Future<void> _selectTheme(AppTheme theme) async {
    final success = await _themeService.setTheme(theme);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thème "${theme.displayName}" appliqué !'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Remet le thème par défaut
  Future<void> _resetToDefault() async {
    final success = await _themeService.resetTheme();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thème réinitialisé !'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Dialog pour la sélection de thème
class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = (screenSize.width * 0.95).clamp(300.0, 600.0);
    final maxHeight = (screenSize.height * 0.9).clamp(400.0, 750.0);

    return Dialog(
      child: Container(
        width: maxWidth,
        height: maxHeight,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.palette, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      AppTexts.themes,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Expanded(child: ThemeSelector()),
          ],
        ),
      ),
    );
  }
}

/// Widget compact pour changer de thème rapidement
class QuickThemeSwitch extends StatefulWidget {
  const QuickThemeSwitch({super.key});

  @override
  State<QuickThemeSwitch> createState() => _QuickThemeSwitchState();
}

class _QuickThemeSwitchState extends State<QuickThemeSwitch> {
  final ThemeService _themeService = ThemeService.instance;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themeService.currentTheme;
    final themeColors = currentTheme.colors;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: themeColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _themeService.previousTheme,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: themeColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 12,
                color: themeColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _buildColorDot(themeColors.primary),
          const SizedBox(width: 2),
          _buildColorDot(themeColors.accent),
          const SizedBox(width: 2),
          _buildColorDot(themeColors.backgroundTop),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              currentTheme.displayName,
              style: TextStyle(
                color: themeColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _themeService.nextTheme,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: themeColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: themeColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
    );
  }
}
