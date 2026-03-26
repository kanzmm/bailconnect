# 🏠 BailConnect - MVP Immobilier Flutter

**Slogan:** *"Louez, signez, payez — en toute confiance."*

Une plateforme mobile innovante de mise en relation entre bailleurs, locataires, agences immobilières et vendeurs à Lubumbashi, RDC.

---

## 📋 Table des matières

1. [Architecture du Projet](#architecture)
2. [Configuration](#configuration)
3. [Installation](#installation)
4. [Structure des Features](#features)
5. [Guide d'Implémentation](#implémentation)
6. [Points d'Extension](#extensions)

---

## 🏗️ Architecture {#architecture}

### Stack Technique

```
FRONTEND: Flutter 3.x + Riverpod
BACKEND: Supabase (PostgreSQL + Auth + Storage)
NAVIGATION: GoRouter
STATE MANAGEMENT: Riverpod
ARCHITECTURE: Clean Architecture + MVVM
```

### Structure des Dossiers

```
lib/
├── main.dart                          # Point d'entrée
├── config/
│   └── router.dart                    # Configuration GoRouter
├── core/
│   ├── config/
│   │   └── supabase_config.dart      # Supabase setup
│   ├── constants/
│   │   ├── enums.dart                # Énumérations
│   │   └── app_constants.dart        # Constantes app
│   ├── providers/
│   │   ├── auth_service.dart         # Service auth
│   │   ├── auth_provider.dart        # Riverpod auth provider
│   │   └── listing_provider.dart     # Riverpod listings provider
│   └── utils/
│       ├── result.dart               # Success/Failure types
│       ├── validator.dart            # Validation
│       └── format_helper.dart        # Formatage
├── features/
│   ├── auth/
│   │   ├── data/                     # Datasources
│   │   ├── domain/                   # Entities, Use Cases
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── listings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── listing_detail_screen.dart
│   ├── chat/                         # À implémenter
│   ├── profile/                      # À implémenter
│   └── payment/                      # À implémenter
└── shared/
    ├── models/
    │   ├── user_model.dart
    │   ├── listing_model.dart
    │   ├── message_model.dart
    │   └── transaction_model.dart
    ├── widgets/                      # Widgets réutilisables
    └── extensions/                   # Extensions Dart
```

---

## ⚙️ Configuration {#configuration}

### 1. Supabase Setup

1. Créer un compte sur [supabase.com](https://supabase.com)
2. Créer un nouveau projet
3. Copier l'URL et la clé anonyme
4. Mettre à jour `lib/core/config/supabase_config.dart`:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 2. Supabase Schema (SQL)

```sql
-- Table Users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR UNIQUE NOT NULL,
  full_name VARCHAR NOT NULL,
  phone VARCHAR,
  profile_image TEXT,
  bio TEXT,
  roles TEXT[] DEFAULT ARRAY['TENANT'],
  verification_status VARCHAR DEFAULT 'unverified',
  rating FLOAT DEFAULT 0,
  review_count INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Table Listings
CREATE TABLE listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR NOT NULL,
  description TEXT NOT NULL,
  type VARCHAR NOT NULL, -- 'RENT' ou 'SALE'
  status VARCHAR DEFAULT 'available', -- available, rented, sold, pending
  price FLOAT NOT NULL,
  city VARCHAR NOT NULL,
  district VARCHAR NOT NULL,
  address TEXT,
  latitude FLOAT,
  longitude FLOAT,
  bedrooms INT DEFAULT 0,
  bathrooms INT DEFAULT 0,
  surface_area FLOAT DEFAULT 0,
  image_urls TEXT[] DEFAULT ARRAY[],
  amenities TEXT[] DEFAULT ARRAY[],
  owner_id UUID NOT NULL REFERENCES users(id),
  is_verified BOOLEAN DEFAULT false,
  views INT DEFAULT 0,
  favorites INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Table Conversations
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_ids UUID[] NOT NULL,
  participant_names TEXT[] NOT NULL,
  last_message_at TIMESTAMP,
  last_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Table Messages
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id),
  sender_id UUID NOT NULL REFERENCES users(id),
  sender_name VARCHAR NOT NULL,
  sender_image TEXT,
  content TEXT NOT NULL,
  image_url TEXT,
  is_read BOOLEAN DEFAULT false,
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Table Transactions
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  listing_id UUID,
  amount FLOAT NOT NULL,
  currency VARCHAR DEFAULT 'Fc',
  provider VARCHAR NOT NULL, -- Orange Money, Airtel Money, etc.
  status VARCHAR DEFAULT 'pending', -- pending, success, failed
  reference_number VARCHAR,
  failure_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);

-- Table Favorites
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  listing_id UUID NOT NULL REFERENCES listings(id),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, listing_id)
);
```

### 3. Permissions Supabase

Activer RLS (Row Level Security) sur toutes les tables et ajouter les politiques appropriées.

---

## 📦 Installation {#installation}

### Prérequis

- Flutter 3.x
- Dart 3.x
- Git

### Étapes

```bash
# 1. Cloner le projet
git clone <repo-url>
cd bailconnect

# 2. Installer les dépendances
flutter pub get

# 3. Générer les fichiers Riverpod (si nécessaire)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Lancer l'app
flutter run
```

---

## 🎯 Features {#features}

### ✅ Implémentées

- [x] **Authentification** (Login/Register)
- [x] **Navigation** GoRouter avec protection des routes
- [x] **Home Screen** avec liste d'annonces
- [x] **Listing Details** avec infos complètes
- [x] **État d'authentification** global (Riverpod)
- [x] **Validation** des formulaires
- [x] **Rôles multiples** (Tenant, Landlord, Agency, Seller)

### 🔄 En cours

- [ ] Création d'annonces (Form + Upload images)
- [ ] Messagerie (Chat en temps réel)
- [ ] Profil utilisateur & gestion des rôles
- [ ] Système de favoris
- [ ] Notifications push

### 📋 À implémenter

- [ ] Paiements (Mobile Money)
- [ ] Contrats numériques
- [ ] Système de rating/reviews
- [ ] Vérification utilisateurs
- [ ] Map view
- [ ] Recherche avancée
- [ ] Historique & statistiques

---

## 📖 Guide d'Implémentation {#implémentation}

### Étape 1: Créer une Annonce

**Fichier à créer:** `lib/features/listings/presentation/create_listing_screen.dart`

```dart
// TODO: Form avec champs:
// - title, description, type, price
// - city, district, address
// - bedrooms, bathrooms, surface_area
// - amenities (multi-select)
// - image upload
```

**Service à implémenter:**
- Ajouter `createListing()` dans `ListingService`
- Utiliser `MultipartFile` pour les images
- Sauvegarder dans Supabase

---

### Étape 2: Messagerie Temps Réel

**Configuration WebSocket:**
```dart
// Utiliser supabase_flutter realtime
final subscription = SupabaseConfig.client
  .from('messages')
  .on(RealtimeListenTypes.postgresChanges, ...)
  .subscribe();
```

---

### Étape 3: Système de Paiement

**Mock Payment (MVP):**
```dart
// Simuler les appels API Mobile Money
// Structure en place pour intégration réelle:
// - Orange Money API
// - Airtel Money API
// - M-Pesa API

class MobileMoneyService {
  Future<Transaction> initiatePayment({
    required double amount,
    required String provider,
    required String phoneNumber,
  }) async {
    // TODO: Appel API du provider
  }
}
```

---

### Étape 4: Notifications Push

```dart
// Setup Firebase Cloud Messaging
// À configurer dans firebase_options.dart
// Token → sauvegarder dans users table
// Notification → afficher avec awesome_notifications
```

---

## 🔌 Points d'Extension {#extensions}

### Ajouter une nouvelle Feature

1. Créer le dossier dans `lib/features/[feature_name]/`
2. Respecter la structure (data/, domain/, presentation/)
3. Créer les modèles dans `lib/shared/models/`
4. Ajouter le provider Riverpod
5. Ajouter les routes dans `lib/config/router.dart`

### Ajouter un Service

```dart
// Créer dans lib/core/providers/
class MyService {
  Future<void> doSomething() async {
    // Utiliser SupabaseConfig.client
  }
}

// Créer un provider
final myServiceProvider = Provider((ref) => MyService());
```

### Ajouter un Widget Réutilisable

```dart
// Créer dans lib/shared/widgets/
class MyCustomWidget extends StatelessWidget {
  // ...
}
```

---

## 🎨 Conventions de Code

- **Noms:** camelCase pour variables, PascalCase pour classes
- **Fichiers:** snake_case
- **Imports:** Organiser par (dart, packages, local)
- **Commentaires:** JSDoc pour fonctions publiques

---

## 🚀 Déploiement

### Building APK/IPA

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Play Store / App Store

TODO: Ajouter configuration de signing

---

## 📞 Support

- Documentation: Voir fichiers `.md` du projet
- Issues: Reporter sur GitHub
- Discord: [Lien serveur]

---

**Créé avec ❤️ pour Lubumbashi**
