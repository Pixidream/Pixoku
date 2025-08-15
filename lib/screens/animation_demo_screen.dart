import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_popup.dart';
import '../widgets/particle_animation.dart';
import '../widgets/animated_sudoku_cell.dart';
import '../utils/constants.dart';

/// Page de démonstration des animations et du système de feedback
class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen>
    with TickerProviderStateMixin {

  final FeedbackService _feedbackService = FeedbackService();

  // État des démonstrations
  bool _showConfirmationPopup = false;
  bool _showVictoryPopup = false;
  bool _showParticles = false;
  bool _showLoadingPopup = false;

  // État des cellules de démonstration
  bool _cell1Selected = false;
  bool _cell2HasError = false;
  bool _cell3Highlighted = false;
  int? _cell1Value;
  int? _cell2Value = 5;
  int? _cell3Value = 3;

  @override
  void initState() {
    super.initState();
    _initializeFeedback();
  }

  Future<void> _initializeFeedback() async {
    await _feedbackService.initialize();
  }

  @override
  void dispose() {
    _feedbackService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démonstration des animations'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Interface principale
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('🎬 Animations des boutons'),
                _buildButtonAnimationsSection(),

                const SizedBox(height: 32),
                _buildSectionTitle('📱 Animations des cellules'),
                _buildCellAnimationsSection(),

                const SizedBox(height: 32),
                _buildSectionTitle('🔊 Système de feedback'),
                _buildFeedbackSection(),

                const SizedBox(height: 32),
                _buildSectionTitle('🎉 Popups animés'),
                _buildPopupsSection(),

                const SizedBox(height: 32),
                _buildSectionTitle('✨ Effets de particules'),
                _buildParticlesSection(),

                const SizedBox(height: 32),
                _buildSectionTitle('⚙️ Paramètres'),
                _buildSettingsSection(),

                const SizedBox(height: 100), // Espace pour les popups
              ],
            ),
          ),

          // Particules de démonstration
          if (_showParticles)
            Positioned.fill(
              child: ParticleEffects.victory(
                isActive: _showParticles,
                onComplete: () {
                  setState(() {
                    _showParticles = false;
                  });
                },
              ),
            ),

          // Popup de confirmation
          if (_showConfirmationPopup)
            Positioned.fill(
              child: AnimatedPopup(
                showPopup: _showConfirmationPopup,
                animationType: PopupAnimationType.scale,
                onDismissed: () {
                  setState(() {
                    _showConfirmationPopup = false;
                  });
                },
                child: SudokuPopup.confirmation(
                  title: 'Démonstration',
                  message: 'Ceci est un exemple de popup de confirmation avec animations.',
                  onConfirm: () {
                    setState(() {
                      _showConfirmationPopup = false;
                    });
                    _feedbackService.successAction();
                  },
                  onCancel: () {
                    setState(() {
                      _showConfirmationPopup = false;
                    });
                  },
                  confirmText: 'Confirmer',
                  cancelText: 'Annuler',
                ),
              ),
            ),

          // Popup de victoire
          if (_showVictoryPopup)
            Positioned.fill(
              child: AnimatedPopup(
                showPopup: _showVictoryPopup,
                animationType: PopupAnimationType.bounceScale,
                onDismissed: () {
                  setState(() {
                    _showVictoryPopup = false;
                  });
                },
                child: SudokuPopup.victory(
                  timeText: '05:42',
                  scoreText: '1250',
                  onMenu: () {
                    setState(() {
                      _showVictoryPopup = false;
                    });
                  },
                  onNewGame: () {
                    setState(() {
                      _showVictoryPopup = false;
                    });
                  },
                ),
              ),
            ),

          // Popup de chargement
          if (_showLoadingPopup)
            Positioned.fill(
              child: AnimatedPopup(
                showPopup: _showLoadingPopup,
                animationType: PopupAnimationType.fade,
                barrierDismissible: false,
                onDismissed: () {
                  setState(() {
                    _showLoadingPopup = false;
                  });
                },
                child: SudokuPopup.loading(
                  message: 'Génération du puzzle...',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildButtonAnimationsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedButton.primary(
                  onPressed: () => _feedbackService.buttonTapped(),
                  child: const Text('Primaire'),
                ),
                AnimatedButton.secondary(
                  onPressed: () => _feedbackService.buttonTapped(),
                  child: const Text('Secondaire'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedButton.icon(
                  onPressed: () => _feedbackService.buttonTapped(),
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
                AnimatedButton.floating(
                  onPressed: () => _feedbackService.buttonTapped(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SudokuButton.number(
                  onPressed: () => _feedbackService.numberPlaced(),
                  number: '7',
                ),
                SudokuButton.action(
                  onPressed: () => _feedbackService.undoAction(),
                  icon: Icons.undo,
                  tooltip: 'Annuler',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellAnimationsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tapez sur les cellules pour voir les animations :',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cellule avec sélection
                Container(
                  width: 60,
                  height: 60,
                  child: AnimatedSudokuCell(
                    value: _cell1Value,
                    isSelected: _cell1Selected,
                    onTap: () {
                      setState(() {
                        _cell1Selected = !_cell1Selected;
                        if (_cell1Selected && _cell1Value == null) {
                          _cell1Value = 1;
                        }
                      });
                    },
                  ),
                ),

                // Cellule avec erreur
                Container(
                  width: 60,
                  height: 60,
                  child: AnimatedSudokuCell(
                    value: _cell2Value,
                    hasError: _cell2HasError,
                    onTap: () {
                      setState(() {
                        _cell2HasError = !_cell2HasError;
                      });
                    },
                  ),
                ),

                // Cellule mise en surbrillance
                Container(
                  width: 60,
                  height: 60,
                  child: AnimatedSudokuCell(
                    value: _cell3Value,
                    isHighlighted: _cell3Highlighted,
                    onTap: () {
                      setState(() {
                        _cell3Highlighted = !_cell3Highlighted;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Sélection', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('Erreur', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('Surbrillance', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.volume_up, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Son: ${_feedbackService.soundEnabled ? "ON" : "OFF"}'),
                const Spacer(),
                Switch(
                  value: _feedbackService.soundEnabled,
                  onChanged: (value) {
                    _feedbackService.setSoundEnabled(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.vibration, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Vibration: ${_feedbackService.hapticEnabled ? "ON" : "OFF"}'),
                const Spacer(),
                Switch(
                  value: _feedbackService.hapticEnabled,
                  onChanged: (value) {
                    _feedbackService.setHapticEnabled(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeedbackButton('Succès', () => _feedbackService.successAction(), Colors.green),
                _buildFeedbackButton('Erreur', () => _feedbackService.errorOccurred(), Colors.red),
                _buildFeedbackButton('Sélection', () => _feedbackService.cellSelected(), Colors.blue),
                _buildFeedbackButton('Nombre', () => _feedbackService.numberPlaced(), Colors.purple),
                _buildFeedbackButton('Annuler', () => _feedbackService.undoAction(), Colors.orange),
                _buildFeedbackButton('Victoire', () => _feedbackService.gameCompleted(), Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackButton(String label, VoidCallback onPressed, Color color) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: color.withOpacity(0.1),
      foregroundColor: color,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      animationStyle: AnimationStyle.bounce,
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildPopupsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedButton.primary(
                  onPressed: () {
                    setState(() {
                      _showConfirmationPopup = true;
                    });
                  },
                  child: const Text('Confirmation'),
                ),
                AnimatedButton.primary(
                  onPressed: () {
                    setState(() {
                      _showVictoryPopup = true;
                    });
                  },
                  child: const Text('Victoire'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedButton.secondary(
              onPressed: () {
                setState(() {
                  _showLoadingPopup = true;
                });

                // Auto-fermer après 3 secondes
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showLoadingPopup = false;
                    });
                  }
                });
              },
              child: const Text('Chargement (3s)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticlesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedButton.primary(
              onPressed: () {
                setState(() {
                  _showParticles = true;
                });
              },
              child: const Text('🎉 Effet de victoire'),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez pour déclencher l\'effet de particules',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.animation),
              title: const Text('Animations'),
              subtitle: const Text('Toutes les animations sont activées dans cette démo'),
              trailing: Switch(
                value: true,
                onChanged: null, // Désactivé pour la démo
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              subtitle: const Text('Cette page démontre le système d\'animations complet'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Système d\'animations Sudoku v1.0'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  ),
                );
              },
