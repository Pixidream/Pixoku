# 🤝 Contributing to Pixoku

Thanks for your interest in Pixoku! All contributions are welcome, whether it's fixing a bug, adding a feature, or improving documentation.

## 🚀 How to contribute

### 1. Report a bug

If you find a bug:
1. Check that it hasn't already been reported in [Issues](https://github.com/yourusername/pixoku/issues)
2. Create a new issue with:
   - A clear description of the problem
   - Steps to reproduce it
   - Expected behavior
   - Screenshots if possible
   - App version and your system (Android/iOS)

### 2. Suggest a feature

Have an idea to improve Pixoku?
1. Open an [Issue](https://github.com/yourusername/pixoku/issues) with the "enhancement" tag
2. Explain your proposal and why it would be useful
3. Let's discuss it together!

### 3. Contribute code

#### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- An editor (VS Code, Android Studio, etc.)

#### Process
1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/your-username/pixoku.git
   cd pixoku
   ```
3. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/my-awesome-feature
   ```
4. **Develop** your feature
5. **Test** your code:
   ```bash
   flutter analyze
   ```
6. **Commit** your changes using conventional commits (see below)
7. **Push** to your fork:
   ```bash
   git push origin feature/my-awesome-feature
   ```
8. **Open a Pull Request** from GitHub

## 📝 Code style

### Dart/Flutter
- Use `flutter format` to format your code
- Follow the [Dart Style Guidelines](https://dart.dev/guides/language/effective-dart/style)
- Name your variables and functions clearly
- Comment complex code

### File structure
```
lib/
├── models/      # Data models
├── screens/     # App screens
├── services/    # Business logic
├── utils/       # Utilities and constants
└── widgets/     # Reusable widgets
```

### Conventional Commits

We use [Conventional Commits](https://www.conventionalcommits.org/) for clear commit history.

Format: `<type>(<scope>): <subject>`

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or fixing tests
- `chore`: Changes to build process or auxiliary tools

**Examples:**
- ✅ `feat(grid): add animation when placing numbers`
- ✅ `fix(theme): correct dark mode colors in notes`
- ✅ `docs: update README with new features`
- ✅ `refactor(game): simplify undo logic`
- ✅ `perf(generator): optimize grid generation algorithm`
- ❌ `Fixed stuff`
- ❌ `Update`

## 📜 Code of conduct

- Be respectful and kind
- Constructive criticism is welcome
- Help new contributors
- Remember this is a project made for fun

## ❓ Questions?

If you have questions:
- Open an [Issue](https://github.com/yourusername/pixoku/issues) with the "question" tag

## 🙏 Thank you!

Every contribution counts, even the smallest. Thanks for taking the time to improve Pixoku!

---

*Happy coding! 🎮*
