# 🔐 Configuration Environment - BailConnect

## ⚠️ IMPORTANT: Ne pas partager ce fichier !

Ce fichier contient vos clés secrètes Supabase. 
**NE PAS** le committer sur Git.

---

## 📝 Étapes de Configuration

### 1. Créer un fichier `.env.example`
```
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SECRET_KEY=your_secret_key_here

# Google Maps (optionnel)
GOOGLE_MAPS_API_KEY=your_google_maps_key_here

# Firebase (optionnel)
FIREBASE_PROJECT_ID=your_firebase_project_id
```

### 2. Configuration dans Flutter

Ouvrir: `lib/core/constants/app_constants.dart`

Remplacer:
```dart
// AVANT:
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

// APRÈS (exemple):
static const String supabaseUrl = 'https://xyzabc123def.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5emFiYzEyM2RlZiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjg0MDAwMDAwLCJleHAiOjE5OTk5OTk5OTl9...';
```

### 3. Récupérer vos clés depuis Supabase

1. Se connecter à Supabase Dashboard
2. Aller dans: **Settings → API**
3. Copier:
   - **Project URL** → `supabaseUrl`
   - **anon key** → `supabaseAnonKey`

---

## 🔑 Où trouver vos clés ?

### Dashboard Supabase
```
1. https://app.supabase.com
2. Sélectionner votre projet
3. Settings (icône engrenage)
4. API tab
5. Project URL et anon key
```

### Format URL
```
https://[PROJECT-REF].supabase.co
Exemple: https://xyzabcdef123456.supabase.co
```

### Format Clé anon
```
Commence par: eyJhbGciOiJIUzI1NiIs...
Longueur: ~200 caractères
```

---

## ✅ Vérification après Configuration

```bash
cd c:\flutter\flutter_application_1\bailconnect

# 1. Nettoyer le cache
flutter clean

# 2. Récupérer les dépendances
flutter pub get

# 3. Vérifier les erreurs
flutter analyze

# 4. Lancer l'app
flutter run -d chrome
```

---

## 🧪 Test de Configuration

Dans l'app:
1. Allez sur l'écran Login
2. Essayez de vous connecter:
   - Email: `demo@bailconnect.com`
   - Password: `Test@123456` (à créer via le register)
3. Si ça fonctionne ✅, la configuration est correcte

---

## 🚨 Erreurs Courantes

### "Failed to initialize Supabase"
```
❌ Les clés ne sont pas bonnes
✓ Vérifier supabaseUrl et supabaseAnonKey
✓ Copier-coller les valeurs correctes depuis Supabase
```

### "Connection refused"
```
❌ Le projet Supabase n'est pas actif
✓ Vérifier dans le dashboard Supabase
✓ Relancer le projet si nécessaire
```

### "Invalid API key"
```
❌ La clé anon est incorrecte
✓ Vérifier que c'est bien la clé "anon" et pas "service_role"
✓ Copier la clé complète sans spaces
```

---

## 🔐 Bonnes Pratiques Sécurité

```
❌ NE PAS committer app_constants.dart modificado
✓ Garder les clés dans un fichier .env non versionné
✓ Utiliser des variables d'environnement en production
✓ Rotationner les clés régulièrement
✓ Utiliser la clé "service_role" seulement en backend
```

---

## 📱 Configuration Multi-Plateforme

### iOS
```
iOS/Runner/Info.plist:
<key>NSBonjourServices</key>
<array>
  <string>_http._tcp</string>
</array>
```

### Android
```
AndroidManifest.xml:
<uses-permission android:name="android.permission.INTERNET" />
```

### Web
```
web/index.html:
<!-- Already configured, no changes needed -->
```

---

**Status**: 🔑 Ready for configuration
