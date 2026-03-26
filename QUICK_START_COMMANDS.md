# ⚡ Quick Start Commands

Commands utiles pour développement rapide de BAILCONNECT.

---

## 🚀 Démarrage Rapide

### Première Setup

```bash
# 1. Cloner et configurer
git clone <repo-url>
cd bailconnect
flutter pub get

# 2. Générer build_runner (si nécessaire)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Configurer Supabase
# Éditer lib/core/config/supabase_config.dart
# Copier l'URL et ANON_KEY depuis supabase.com

# 4. Lancer l'app
flutter run
```

---

## 📱 Build & Run

### Android

```bash
# Debug
flutter run -d <device-id> --debug

# Release
flutter build apk --release

# Install APK
adb install build/app/outputs/apk/release/app-release.apk
```

### iOS

```bash
# Debug
flutter run -d <device-id>

# Release
flutter build ios --release
```

### Web

```bash
flutter run -d chrome
flutter build web
```

---

## 🧹 Maintenance

### Clean & Fresh Build

```bash
# Supprimer tous les artifacts
flutter clean

# Réinstaller dépendances
rm pubspec.lock
flutter pub get

# Rebuild everything
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run
```

### Vérification Qualité Code

```bash
# Analyser le code
dart analyze lib/

# Formater
dart format lib/ -l 100

# Fix automatique (issues mineures)
dart fix --apply lib/
```

---

## 🔍 Debug & Logs

### Afficher les Logs

```bash
# Logs verbeux (détaillé)
flutter logs -v

# Logs avec timestamps
flutter logs -t

# Filtrer les logs
flutter logs | grep "ERROR"
flutter logs | grep "bailconnect"
```

### Dart DevTools

```bash
# Lancer DevTools
flutter pub global activate devtools
devtools

# Ou depuis l'app
flutter run
# Appuyer sur 'd' dans le terminal pour ouvrir DevTools
```

### Widgets Inspector

```bash
# Lancer avec inspector ouvert
flutter run -v

# Toggle dans terminal:
# 'i' = toggle Inspector
# 't' = toggle Tracking Mode
# 'w' = highlight widgets
```

---

## 📦 Dépendances

### Ajouter Dépendance

```bash
# Ajouter
flutter pub add package_name

# Ajouter de pub.dev
flutter pub add dev_package --dev

# Spécifier version
flutter pub add package_name:'^1.0.0'

# Version locale
flutter pub add local_package --path=../local_package
```

### Mettre à Jour

```bash
# Toutes dépendances
flutter pub upgrade

# Une dépendance
flutter pub upgrade package_name

# Vérifier outdated
flutter pub outdated
```

### Supprimer

```bash
flutter pub remove package_name
```

---

## 🗄️ Base de Données

### Supabase Local (Optionnel)

```bash
# Installer supabase CLI
npm install -g supabase

# Démarrer local instance
supabase start

# Stop
supabase stop

# Accéder à DB
supabase db push
```

### Reset Migration

```bash
# Reset complètement
supabase db reset

# Créer migration
supabase migration new <name>

# Apply migrations
supabase migration execute
```

---

## 🧪 Tests

### Unit Tests

```bash
# Tous les tests
flutter test

# Un fichier test
flutter test test/services/auth_service_test.dart

# Avec coverage
flutter test --coverage

# Reporter coverage
# Installer: pub global activate coverage
# coverage --input=coverage/lcov.info --output=coverage/html
```

### Widget Tests

```bash
# Tous les widget tests
flutter test test/features/

# Un widget test spécifique
flutter test test/features/auth/login_screen_test.dart

# Watch mode (auto-rerun)
flutter test --watch
```

### Intégration Tests

```bash
# Sur dispositif/émulateur
flutter drive --target=test_driver/app.dart

# Headless
flutter drive --target=test_driver/app.dart --headless
```

---

## 🎨 UI/UX

### Hot Reload vs Hot Restart

```bash
# Hot Reload (Fast, preserves état)
# Dans terminal pendant flutter run: 'r'

# Hot Restart (Lent, reset état)
# Dans terminal: 'R'

# Full Restart (Super lent, recompile everything)
# CTRL+C puis flutter run
```

### Frame Rate & Performance

```bash
# Afficher FPS et frame time
# Dans DevTools → Performance tab
# Ou appuyer 'p' pendant flutter run

# Profile build
flutter run --profile

# Release build (plus rapide)
flutter run --release
```

---

## 🚨 Dépannage Rapide

### "Module not found"

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Build fails"

```bash
flutter clean
rm pubspec.lock
flutter pub get
flutter run
```

### "Permission denied"

```bash
# Android
chmod +x android/gradlew

# iOS
chmod +x ios/Pods/
```

### "Port déjà utilisé"

```bash
flutter run --host=localhost --port=8081
```

### "Emulator not found"

```bash
# Lister devices
flutter devices

# Créer emulator
flutter emulators --create --name nexus

# Lancer emulator
flutter emulators --launch nexus
```

---

## 📊 Commandes Utiles Avancées

### GIT Integration

```bash
# Clone & setup
git clone <repo>
cd bailconnect
git checkout -b feature/my-feature

# Commit with lint check
git add .
dart analyze lib/
git commit -m "feat: added favorites feature"

# Push with pre-commit hook
git push origin feature/my-feature
```

### Release Build

```bash
# Augmenter version
# Éditer pubspec.yaml: version: 1.0.0+1

# Build APK
flutter build apk --release --split-per-abi

# Outputs:
# build/app/outputs/apk/release/app-arm64-v8a-release.apk
# build/app/outputs/apk/release/app-armeabi-v7a-release.apk
# build/app/outputs/apk/release/app-x86_64-release.apk

# Build Bundle (Play Store)
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab

# Build IPA (App Store)
flutter build ios --release
```

### CLI Arguments

```bash
# Verbose logging
flutter run -v

# Specific device
flutter run -d 'iPhone 13'

# Orientation
flutter run --orientation=portraitUp

# Flavor
flutter run --flavor prod -t lib/main_prod.dart

# Enable assertions
flutter run --enable-asserts

# Skip build
flutter run --no-build
```

---

## 📝 Fichiers de Projet Important

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Dépendances & metadata |
| `analysis_options.yaml` | Linter rules |
| `lib/main.dart` | Entry point |
| `lib/config/router.dart` | Routing |
| `lib/core/config/supabase_config.dart` | Backend config |
| `.env` | Environment variables (gitignore) |
| `README.md` | Project documentation |

---

## 🎯 Workflow Développement Typique

```bash
# 1. Pull latest changes
git pull origin main

# 2. Create feature branch
git checkout -b feature/new-feature

# 3. Setup environment
flutter clean
flutter pub get

# 4. Develop with hot reload
flutter run

# 5. Run tests
flutter test

# 6. Format & analyze
dart format lib/
dart analyze lib/

# 7. Commit
git add .
git commit -m "feat: implement new feature"

# 8. Push
git push origin feature/new-feature

# 9. Create Pull Request on GitHub
```

---

## 🔗 Liens Utiles

| Resource | Link |
|----------|------|
| Flutter Docs | https://flutter.dev |
| Dart Docs | https://dart.dev |
| Riverpod Docs | https://riverpod.dev |
| GoRouter Docs | https://pub.dev/packages/go_router |
| Supabase Docs | https://supabase.com/docs |
| Pub.dev Packages | https://pub.dev |

---

## 💾 Snippets Utiles

### Créer un Provider Rapidement

```dart
// Copy-paste template
final myProvider = FutureProvider<List<T>>((ref) async {
  return await MyService.instance.fetchData();
});
```

### Créer un Screen Rapidement

```dart
// Copy-paste template
class MyScreen extends ConsumerWidget {
  const MyScreen();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: const Center(child: Text('Content')),
    );
  }
}
```

### Créer un Widget Réutilisable

```dart
// Copy-paste template
class MyWidget extends StatelessWidget {
  final String text;
  
  const MyWidget({required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(text),
    );
  }
}
```

---

## ⌨️ Keyboard Shortcuts Terminal Flutter

| Key | Action |
|-----|--------|
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | Help menu |
| `q` | Quit |
| `d` | Detach |
| `i` | Toggle inspector |
| `w` | Highlight widgets |
| `p` | Toggle performance overlay |
| `o` | Toggle platform (Android ↔️ iOS) |

---

## 📞 Support & Help

```bash
# Doctor (diagnostique)
flutter doctor

# Full verbose diagnostique
flutter doctor -v

# Test config
flutter doctor --android-licenses

# Afficher Flutter version
flutter --version

# Afficher Dart version
dart --version
```

---

**Créé:** 2026-03-25  
**Mise à jour:** Régulièrement  
**Status:** ✅ Production-Ready

