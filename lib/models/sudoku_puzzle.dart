import '../utils/constants.dart';

/// Modèle représentant un puzzle de Sudoku complet
class SudokuPuzzle {
  /// Grille de jeu avec les valeurs actuelles (0 = cellule vide)
  final List<List<int>> grid;

  /// Grille solution complète
  final List<List<int>> solution;

  /// Indique si une cellule est fixe (donnée au départ) ou modifiable
  final List<List<bool>> isFixed;

  /// Notes pour chaque cellule (chiffres possibles)
  final List<List<Set<int>>> notes;

  const SudokuPuzzle({
    required this.grid,
    required this.solution,
    required this.isFixed,
    required this.notes,
  });

  /// Crée une copie du puzzle avec des modifications
  SudokuPuzzle copyWith({
    List<List<int>>? grid,
    List<List<int>>? solution,
    List<List<bool>>? isFixed,
    List<List<Set<int>>>? notes,
  }) {
    return SudokuPuzzle(
      grid: grid ?? this.grid.map((row) => List<int>.from(row)).toList(),
      solution: solution ?? this.solution.map((row) => List<int>.from(row)).toList(),
      isFixed: isFixed ?? this.isFixed.map((row) => List<bool>.from(row)).toList(),
      notes: notes ?? this.notes.map((row) => row.map((cell) => Set<int>.from(cell)).toList()).toList(),
    );
  }

  /// Convertit le puzzle en Map pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'grid': grid,
      'solution': solution,
      'isFixed': isFixed,
      'notes': notes.map((row) => row.map((cell) => cell.toList()).toList()).toList(),
    };
  }

  /// Crée un puzzle depuis un Map (depuis la sauvegarde)
  factory SudokuPuzzle.fromJson(Map<String, dynamic> json) {
    // Gérer les notes (rétro-compatibilité si pas présentes)
    List<List<Set<int>>> parsedNotes;
    if (json.containsKey('notes')) {
      parsedNotes = (json['notes'] as List)
          .map((row) => (row as List)
              .map((cell) => Set<int>.from(cell as List))
              .toList())
          .toList();
    } else {
      // Créer des notes vides pour la rétro-compatibilité
      parsedNotes = List.generate(
        GameConstants.gridSize,
        (i) => List.generate(
          GameConstants.gridSize,
          (j) => <int>{},
        ),
      );
    }

    return SudokuPuzzle(
      grid: (json['grid'] as List)
          .map((row) => (row as List).cast<int>())
          .toList(),
      solution: (json['solution'] as List)
          .map((row) => (row as List).cast<int>())
          .toList(),
      isFixed: (json['isFixed'] as List)
          .map((row) => (row as List).cast<bool>())
          .toList(),
      notes: parsedNotes,
    );
  }

  /// Vérifie si une valeur peut être placée à une position donnée
  bool isValidMove(int row, int col, int num) {
    // Vérifier la ligne
    for (int i = 0; i < GameConstants.gridSize; i++) {
      if (i != col && grid[row][i] == num) return false;
    }

    // Vérifier la colonne
    for (int i = 0; i < GameConstants.gridSize; i++) {
      if (i != row && grid[i][col] == num) return false;
    }

    // Vérifier le bloc 3x3
    int blockRow = (row ~/ GameConstants.blockSize) * GameConstants.blockSize;
    int blockCol = (col ~/ GameConstants.blockSize) * GameConstants.blockSize;
    for (int i = blockRow; i < blockRow + GameConstants.blockSize; i++) {
      for (int j = blockCol; j < blockCol + GameConstants.blockSize; j++) {
        if (i != row && j != col && grid[i][j] == num) return false;
      }
    }

    return true;
  }

  /// Compte le nombre d'occurrences d'un chiffre dans la grille
  int getNumberCount(int number) {
    int count = 0;
    for (int i = 0; i < GameConstants.gridSize; i++) {
      for (int j = 0; j < GameConstants.gridSize; j++) {
        if (grid[i][j] == number) {
          count++;
        }
      }
    }
    return count;
  }

  /// Vérifie si le puzzle est complètement résolu
  bool isComplete() {
    for (int i = 0; i < GameConstants.gridSize; i++) {
      for (int j = 0; j < GameConstants.gridSize; j++) {
        if (grid[i][j] == 0 || grid[i][j] != solution[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  /// Vérifie si deux cellules sont dans la même région (ligne, colonne ou bloc)
  bool isInSameRegion(int row1, int col1, int row2, int col2) {
    // Même ligne ou même colonne
    if (row1 == row2 || col1 == col2) return true;

    // Même bloc 3x3
    int block1Row = row1 ~/ GameConstants.blockSize;
    int block1Col = col1 ~/ GameConstants.blockSize;
    int block2Row = row2 ~/ GameConstants.blockSize;
    int block2Col = col2 ~/ GameConstants.blockSize;

    return block1Row == block2Row && block1Col == block2Col;
  }

  /// Ajoute une note à une cellule
  SudokuPuzzle addNote(int row, int col, int number) {
    if (isFixed[row][col] || grid[row][col] != 0) {
      return this; // Pas de notes sur les cellules fixes ou remplies
    }

    final newNotes = notes.map((r) => r.map((cell) => Set<int>.from(cell)).toList()).toList();
    newNotes[row][col].add(number);

    return copyWith(notes: newNotes);
  }

  /// Supprime une note d'une cellule
  SudokuPuzzle removeNote(int row, int col, int number) {
    final newNotes = notes.map((r) => r.map((cell) => Set<int>.from(cell)).toList()).toList();
    newNotes[row][col].remove(number);

    return copyWith(notes: newNotes);
  }

  /// Bascule une note (ajoute si absente, supprime si présente)
  SudokuPuzzle toggleNote(int row, int col, int number) {
    if (isFixed[row][col] || grid[row][col] != 0) {
      return this; // Pas de notes sur les cellules fixes ou remplies
    }

    if (notes[row][col].contains(number)) {
      return removeNote(row, col, number);
    } else {
      return addNote(row, col, number);
    }
  }

  /// Efface toutes les notes d'une cellule
  SudokuPuzzle clearNotes(int row, int col) {
    final newNotes = notes.map((r) => r.map((cell) => Set<int>.from(cell)).toList()).toList();
    newNotes[row][col].clear();

    return copyWith(notes: newNotes);
  }

  /// Efface automatiquement les notes invalides après placement d'un nombre
  SudokuPuzzle clearInvalidNotes(int row, int col, int number) {
    final newNotes = notes.map((r) => r.map((cell) => Set<int>.from(cell)).toList()).toList();

    // Effacer les notes dans la même ligne
    for (int c = 0; c < GameConstants.gridSize; c++) {
      newNotes[row][c].remove(number);
    }

    // Effacer les notes dans la même colonne
    for (int r = 0; r < GameConstants.gridSize; r++) {
      newNotes[r][col].remove(number);
    }

    // Effacer les notes dans le même bloc 3x3
    int blockRow = (row ~/ GameConstants.blockSize) * GameConstants.blockSize;
    int blockCol = (col ~/ GameConstants.blockSize) * GameConstants.blockSize;
    for (int r = blockRow; r < blockRow + GameConstants.blockSize; r++) {
      for (int c = blockCol; c < blockCol + GameConstants.blockSize; c++) {
        newNotes[r][c].remove(number);
      }
    }

    return copyWith(notes: newNotes);
  }

  /// Vérifie si une cellule a des notes
  bool hasNotes(int row, int col) {
    return notes[row][col].isNotEmpty;
  }

  /// Obtient les notes d'une cellule
  Set<int> getNotes(int row, int col) {
    return Set<int>.from(notes[row][col]);
  }

  /// Crée un puzzle avec des notes vides
  static SudokuPuzzle withEmptyNotes(
    List<List<int>> grid,
    List<List<int>> solution,
    List<List<bool>> isFixed,
  ) {
    final emptyNotes = List.generate(
      GameConstants.gridSize,
      (i) => List.generate(
        GameConstants.gridSize,
        (j) => <int>{},
      ),
    );

    return SudokuPuzzle(
      grid: grid,
      solution: solution,
      isFixed: isFixed,
      notes: emptyNotes,
    );
  }
}
