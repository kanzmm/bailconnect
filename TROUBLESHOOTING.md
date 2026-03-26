# 🐛 Dépannage & Erreurs Courantes

Résolutions rapides pour les problèmes fréquents dans BAILCONNECT.

---

## ❌ Erreurs Supabase

### "Invalid API Key"
```
Error: Invalid API Key provided
```

**Solution:**
1. Vérifier `lib/core/config/supabase_config.dart`
2. Copier la bonne clé depuis [supabase.com](https://app.supabase.com)
3. S'assurer que c'est la clé **anonyme** (pas la service key)

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'eyJhbGc...'; // 🔑 À remplacer
```

---

### "Table does not exist"
```
Error: relation "listings" does not exist
```

**Solution:**
1. Créer les tables dans Supabase SQL Editor
2. Exécuter le script SQL depuis `README.md` → Configuration → Supabase Schema
3. Activer RLS (Row Level Security)

```sql
-- Exemple pour table users
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  full_name VARCHAR NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

---

### "Permission denied" sur requête
```
Error: 403 Forbidden
```

**Solution:**
1. Vérifier les règles RLS dans Supabase Dashboard
2. S'assurer que l'utilisateur a accès à ses propres données

```sql
-- Politique RLS pour que chacun voie ses propres données
CREATE POLICY "Users can see own data"
ON users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own data"
ON users FOR UPDATE
USING (auth.uid() = id);
```

---

## ❌ Erreurs Riverpod

### "Provider not found"
```
ProviderException: Provider not found
```

**Solution:**
- Le provider n'est pas accessible (vérifier l'import)
- Vérifier que le widget est enveloppé par `ProviderScope`

```dart
// ❌ MAUVAIS
void main() {
  runApp(const MyApp()); // Oubli ProviderScope
}

// ✅ BON
void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}
```

---

### "Type mismatch in provider"
```
error: The return type is not a subtype of the expected type
```

**Solution:**
Vérifier que le type retourné par le provider match le type déclaré.

```dart
// ❌ MAUVAIS
final userProvider = Provider<User>((ref) {
  return null; // null n'est pas User
});

// ✅ BON
final userProvider = Provider<User?>((ref) {
  return null; // null est User?
});
```

---

### "AsyncValue.loading persists"
Le widget reste en state "loading".

**Solution:**
1. Vérifier que le FutureProvider retourne complètement
2. Ajouter logging pour debugger

```dart
final listingProvider = FutureProvider<List<Listing>>((ref) async {
  print('🔄 Fetching listings...'); // Debug log
  final listings = await ListingService.instance.getListings();
  print('✅ Listings loaded: ${listings.length}'); // Debug log
  return listings;
});
```

---

## ❌ Erreurs GoRouter

### "Redirect loop"
Navigation infinie qui refresh la page.

**Solution:**
Les conditions de redirect doivent être mutuellement exclusives.

```dart
// ❌ MAUVAIS: Boucle infinie
redirect: (context, state) {
  if (!isAuthenticated) return '/login';
  if (isAuthenticated && location == '/login') return '/home';
  // Oups: Si pas auth → /login. Mais /login n'existe pas = redirect boucle
}

// ✅ BON: Logique claire
redirect: (context, state) {
  final location = state.location;
  
  // Rule 1: Non-auth ne peut aller que sur /login, /register
  if (!isAuthenticated) {
    if (location == '/login' || location == '/register') return null;
    return '/login';
  }
  
  // Rule 2: Auth ne peut pas aller sur /login, /register
  if (isAuthenticated && (location == '/login' || location == '/register')) {
    return '/home';
  }
  
  return null; // Pas de redirect
}
```

---

### "Route not found"
```
Error: Could not find a matching route for path
```

**Solution:**
1. Vérifier que la route existe dans `router.dart`
2. Vérifier les paramètres sont passés correctement

```dart
// ❌ MAUVAIS
context.go('/listing'); // Route est /listing/:id

// ✅ BON
context.go('/listing/$listingId'); // Passer le paramètre
```

---

## ❌ Erreurs d'Authentification

### "User already exists"
```
Error: User with this email already registered
```

**Solution:**
- L'email est déjà enregistré
- Utiliser une autre adresse email
- Ou vérifier préalablement avec `checkUserExists()`

```dart
final exists = await AuthService.instance.checkUserExists(email);
if (exists) {
  showError('Email déjà utilisé');
}
```

---

### "Invalid email format"
```
Error: Invalid email format
```

**Solution:**
Vérifier le regex du validateur

```dart
// Utiliser le validateur centralisé
final error = Validator.validateEmail(email);
if (error != null) {
  print('Email invalide: $error');
}

// Formats valides:
// ✅ user@example.com
// ✅ user.name@example.co.uk
// ❌ user@
// ❌ user@@example.com
```

---

### "Password too short"
```
Error: Password must be at least 6 characters
```

**Solution:**
Respecter le minimum de 6 caractères.

```dart
// Utiliser le validateur
final error = Validator.validatePassword(password);
if (error != null) {
  print(error);
}

// Règles:
// - Minimum 6 caractères
// - Aucun caractère spécial requis (MVP)
```

---

## ❌ Erreurs de Validation

### "Campo requerido" mais input au validation

Livelihood validator ne s'appelle pas.

**Solution:**
Vérifier que le formKey validation est appelée.

```dart
// ❌ MAUVAIS
if (_emailController.text.isEmpty) { // Validation manuelle
  showError('Email requis');
}

// ✅ BON
if (_formKey.currentState!.validate()) { // FormState validation
  // Tous les TextFormField validators ont été appelés
  submitForm();
}
```

---

## ❌ Erreurs d'Images

### "Failed to load image"
```
Image.network: Connection timeout
```

**Solution:**
1. Vérifier que l'URL est accessible
2. Utiliser CachedNetworkImage avec fallback

```dart
// ❌ MAUVAIS
Image.network(url) // Pas de gestion d'erreur

// ✅ BON
CachedNetworkImage(
  imageUrl: url,
  errorWidget: (_, __, ___) => PlaceholderImage(),
  placeholder: (_, __) => LoadingWidget(),
)
```

---

### "Image upload fails"
Impossible d'envoyer une image à Supabase Storage.

**Solution:**
1. Vérifier que le bucket existe et est public
2. Vérifier les permissions RLS du bucket
3. Tester l'upload manuellement dans Supabase Dashboard

```dart
// Créer un bucket public "listings"
// Dans Supabase Dashboard → Storage → Create new bucket
// Cocher "Make it public"

// Code pour upload:
final file = File(pickedFile.path);
final fileName = 'listings/${DateTime.now().millisecondsSinceEpoch}.jpg';

await SupabaseConfig.client.storage.from('listings').upload(fileName, file);
```

---

## ⚠️ Erreurs de Performance

### "UI freezes during load"
L'interface se gèle lors du chargement des données.

**Solution:**
Utiliser `compute()` pour exécuter du travail lourd sur un isolate.

```dart
import 'dart:isolate';

// Pour traitement lourd (parsing gros data, etc.)
final results = await compute(heavyComputation, largeList);

// Typiquement non nécessaire pour API calls
```

---

### "Too many API calls"
Trop de requêtes Supabase, dépassement de quotas.

**Solution:**
1. Utiliser le caching Riverpod (ref.cache)
2. Implémenter debounce/throttle sur la recherche
3. Utiliser ref.refresh() manuellement au lieu de polling

```dart
// ❌ MAUVAIS: Appel à chaque keystroke
TextFormField(
  onChanged: (value) => ref.read(searchProvider.notifier).search(value),
)

// ✅ BON: Utiliser debounce
Timer? _debounce;

onChanged: (value) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    ref.read(searchProvider.notifier).search(value);
  });
}
```

---

## 🔧 Diagnostique Utiles

### Vérifier la version Flutter
```bash
flutter --version
# Expected: Flutter 3.x, Dart 3.x
```

### Vérifier les dépendances
```bash
flutter pub get
flutter pub outdated
```

### Lancer l'analyseur
```bash
dart analyze lib/
# Doit montrer 0 erreurs
```

### Formater le code
```bash
dart format lib/ -l 100
```

### Logs en temps réel
```bash
flutter logs -v
# Verbose logging pour debug
```

---

## 📱 Problèmes Spécifiques à Android

### "Gradle build failed"
```
Error: Failed to build Android project
```

**Solution:**
```bash
# Nettoyer et rebuild
flutter clean
rm -rf android/.gradle
flutter pub get
flutter build apk
```

---

### "MainActivity.kt not found"
Fichier main activity manquant.

**Solution:**
Régénérer Android files:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## 📱 Problèmes Spécifiques à iOS

### "Pods resolution failed"
Dependances iOS cassées.

**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
cd ios
pod install
cd ..
```

---

## 🔍 Debug Tips

### Ajouter des prints
```dart
// Utiliser debugPrint pour Flutter logs
import 'package:flutter/foundation.dart';

debugPrint('🔍 DEBUG: User: $user');
debugPrint('⚠️ WARNING: Potential issue');
debugPrint('❌ ERROR: Something went wrong');
```

### Widget Inspector
```bash
# Lancer avec inspection activée
flutter run -v
# Puis: Dans VS Code → "Toggle Debug Paint"
```

### Bloc logging
```dart
// Observer les changements d'état
ref.listen(myProvider, (previous, next) {
  debugPrint('État avant: $previous');
  debugPrint('État après: $next');
});
```

---

## 🆘 Quand Tout Casse

### "Works on my machine" problem

```bash
# 1. Clean complet
flutter clean
rm -rf pubspec.lock
rm -rf .dart_tool

# 2. Reinstaller dépendances
flutter pub get

# 3. Rebuild
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run
```

### Rapporter un Bug

Si c'est une vraie issue (pas config), créer un rapport en incluant:
1. **Flutter version:** `flutter --version`
2. **Code minimal** qui reproduit l'erreur
3. **Logs complets:** `flutter logs -v`
4. **Plateforme:** Android/iOS/Web
5. **Steps to reproduce:** Exact sequence

---

## 💡 Ressources Debug

| Problème | Outil |
|----------|-------|
| Crash app | Android Studio Logcat |
| Perf lente | Flutter DevTools (Performance) |
| Mémoire | DevTools Memory tab |
| Widget tree | DevTools Inspector |
| Réseau | Wireshark ou Firebase Console |
| Auth | Supabase Dashboard Logs |

---

**Version:** 1.0  
**Last Updated:** 2026-03-25  
**Support:** Consulter la doc technique ou GitHub Issues
