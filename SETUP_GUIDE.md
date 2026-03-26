# 🚀 Guide Setup Complet - BailConnect

## ÉTAPE 1️⃣: Configuration Supabase (5 min)

### 1. Créer un projet Supabase
```
1. Aller sur https://supabase.com
2. Cliquer "Start Your Project"
3. Se connecter ou créer un compte
4. Créer un nouveau projet
   - Name: bailconnect
   - Database Password: (choisir un mot de passe fort)
   - Region: (choisir le plus proche)
5. Attendre 2-3 minutes l'initialisation
```

### 2. Récupérer les clés d'accès
```
1. Dans Supabase Dashboard → Settings → API
2. Copier:
   - Project Reference (c'est le URL)
   - Anon key (clé publique)
   - Secret key (clé privée - à garder secrète)
3. Garder ces valeurs précieusement
```

### 3. Initialiser la base de données
```
1. Dans Supabase → SQL Editor
2. Créer une nouvelle query
3. Copier le contenu de: database/schema.sql
4. Exécuter le script
5. Attendre la confirmation "success"
```

### 4. Configurer le Storage
```
1. Supabase → Storage
2. Créer deux buckets (+):
   - "listings-images"
     ✓ Make it public
   - "profile-images"
     ✓ Make it public
3. Définir les politiques d'accès:
   - Lecture: Public
   - Écriture: Authenticated users
```

---

## ÉTAPE 2️⃣: Configurer l'App Flutter

### 1. Mettre à jour app_constants.dart
```dart
// Remplacer dans lib/core/constants/app_constants.dart

// YOUR_SUPABASE_URL → https://xxxxxabcdef.supabase.co
static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';

// YOUR_SUPABASE_ANON_KEY → votre clé anon complète
static const String supabaseAnonKey = 'votre_clé_anon_complète';
```

Exemple:
```dart
static const String supabaseUrl = 'https://xyzabcdef123456.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### 2. Redémarrer l'app
```bash
# Tuer le processus flutter run en cours (Ctrl+C)
# Relancer:
flutter clean
flutter pub get
flutter run -d chrome
```

---

## ÉTAPE 3️⃣: Tester la Configuration

### ✅ Vérifier que tout fonctionne:

1. **Login**: Essayer de se connecter avec:
   - Email: `demo@bailconnect.com`
   - Password: `Test@123456`

2. **HomeScreen**: 
   - ✓ Les annonces se chargent depuis Supabase
   - ✓ Les filtres fonctionnent
   - ✓ Pagination OK

3. **Profil**:
   - ✓ Photo de profil affichée
   - ✓ Statistiques correctes
   - ✓ Édition du profil fonctionne

4. **Chat**:
   - ✓ Liste des conversations chargée
   - ✓ Création de nouvelles conversations possible
   - ✓ Messages persistés

---

## 🔧 Configuration Google Maps (OPTIONNEL)

```
1. Aller sur: https://console.cloud.google.com
2. Créer un projet
3. Activer: Maps SDK, Places API, Geocoding
4. Créer une clé API
5. La mettre dans app_constants.dart:

static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_KEY';
```

---

## 📱 Commandes Utiles

```bash
# Lancer l'app sur Chrome
flutter run -d chrome

# Vérifier les erreurs
flutter analyze

# Nettoyer le cache
flutter clean && flutter pub get

# Formater le code
dart format lib/

# Voir les logs
flutter logs

# Run sur émulateur Android
flutter run -d emulator-5554
```

---

## ⚠️ Problèmes Courants

### Erreur: "Failed to connect to Supabase"
```
→ Vérifier que supabaseUrl et supabaseAnonKey sont corrects
→ Vérifier la connexion internet
→ Vérifier que le projet Supabase est actif
```

### Erreur: "Row level security violated"
```
→ Vérifier les politiques RLS dans Supabase
→ S'assurer que l'utilisateur est authentifié
→ Vérifier les permissions dans SQL Editor
```

### Erreur: "Image upload failed"
```
→ Vérifier que les buckets existent
→ Vérifier que "public" est activé
→ Vérifier les permissions RLS
```

---

## ✨ Prochaines Étapes

Une fois configuré, vous pouvez:

1. **Créer des annonces**
   - Clic sur le bouton + (FAB)
   - Remplir le formulaire
   - Sauvegarder dans Supabase

2. **Chatter avec d'autres utilisateurs**
   - Clic sur Messages
   - Sélectionner une conversation
   - Envoyer des messages en temps réel

3. **Gérer votre profil**
   - Clic sur Profil
   - Modifier vos informations
   - Voir vos annonces et avis

---

## 📞 Support

Pour toute question ou erreur:
1. Consulter les logs: `flutter logs`
2. Vérifier le dashboard Supabase
3. Vérifier les permissions RLS
4. Consulter la documentation Supabase

---

**Status**: 🟢 Ready for production once configured
