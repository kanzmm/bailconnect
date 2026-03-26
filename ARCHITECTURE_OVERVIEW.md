# ✨ Architecture & Tech Stack - BAILCONNECT

**Référence rapide de l'architecture et technologies.**

---

## 🎯 Vue d'Ensemble

BAILCONNECT est une **plateforme immobilière** complète pour Lubumbashi (RDC) permettant aux bailleurs, locataires, agences et vendeurs d'interagir en confiance.

### Type de Projet
- ✅ **Mobile-first** (Flutter)
- ✅ **MVP Production-ready**
- ✅ **Scale-ready** (Clean Architecture)
- ✅ **Multi-platform** (Android, iOS, Web)

---

## 📱 Stack Technique

```
┌─────────────────────────────────────────────────────┐
│                    FRONTEND LAYER                    │
│  Flutter 3.x + Dart 3.x + Material Design 3         │
└─────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────┐
│                  STATE MANAGEMENT                   │
│  Riverpod (flutter_riverpod: ^2.4.0)               │
│  - Provider (read-only)                             │
│  - StateNotifier (mutable state)                    │
│  - AsyncValue (async operations)                   │
└─────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────┐
│                    NAVIGATION                        │
│  GoRouter (^13.0.0) - Web-first routing            │
│  - Declarative routes                               │
│  - Deep linking                                     │
│  - Auth redirects                                   │
└─────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────┐
│                   BACKEND LAYER                      │
│  Supabase (supabase_flutter: ^1.10.0)              │
│  - PostgreSQL Database                              │
│  - Email/Password Auth                              │
│  - Row Level Security (RLS)                         │
│  - Realtime Subscriptions                           │
│  - File Storage                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🏗️ Architecture Pattern

### Clean Architecture + MVVM

```
┌──────────────────────────────────────────┐
│         PRESENTATION LAYER               │
│  Screens, Widgets, ConsumerWidgets      │
│  (Events handled, State displayed)       │
└──────────────────────────────────────────┘
            ↓ (Riverpod)
┌──────────────────────────────────────────┐
│         DOMAIN LAYER                     │
│  Entities, UseCases, Repositories (I)   │
│  (Business logic - Framework agnostic)  │
└──────────────────────────────────────────┘
            ↓ (Implementations)
┌──────────────────────────────────────────┐
│         DATA LAYER                       │
│  Datasources, Models, Repositories (I)  │
│  (API calls, Database queries)           │
└──────────────────────────────────────────┘
```

### Folder Structure

```
lib/
├── main.dart                          [Entry Point]
├── config/
│   └── router.dart                    [Navigation]
├── core/
│   ├── config/
│   │   └── supabase_config.dart      [Backend Setup]
│   ├── constants/
│   │   ├── enums.dart                [User roles, listing types]
│   │   └── app_constants.dart        [App config]
│   ├── providers/
│   │   ├── auth_service.dart         [Auth logic]
│   │   ├── auth_provider.dart        [Auth state]
│   │   └── listing_provider.dart     [Listings state]
│   └── utils/
│       ├── result.dart               [Success/Failure wrapper]
│       ├── validator.dart            [Input validation]
│       └── format_helper.dart        [Display formatting]
├── features/  (Clean Architecture per feature)
│   ├── auth/
│   │   ├── data/                     [Datasources]
│   │   ├── domain/                   [Entities, use cases]
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── listings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── listing_detail_screen.dart
│   ├── chat/                         [TODO]
│   ├── profile/                      [TODO]
│   └── payment/                      [TODO]
└── shared/
    ├── models/
    │   ├── user_model.dart
    │   ├── listing_model.dart
    │   ├── message_model.dart
    │   └── transaction_model.dart
    ├── widgets/                      [Reusable UI]
    └── extensions/                   [Dart extensions]
```

---

## 🔑 Key Features

### ✅ Implémentées (Prêtes)

| Feature | Details |
|---------|---------|
| **Authentification** | Register/Login multi-role |
| **Listing Browse** | Grid view with search + filters |
| **Listing Detail** | Full info avec owner contact |
| **Navigation** | GoRouter protected routes |
| **State Management** | Riverpod (auth + listings) |
| **Validation** | Form fields + French messages |
| **Formatting** | Currency (Fc), dates, phone |

### 🔄 En Cours (50%)

| Feature | Status |
|---------|--------|
| **Create Listing** | Form structure ready, image upload TODO |
| **Favoris** | Pattern designed, not implemented |
| **Search** | Filter chips ready, backend TODO |

### ⏳ À Faire (0%)

| Feature | Priority |
|---------|----------|
| **Messagerie** | Haute (WebSocket/Realtime) |
| **Paiements** | Haute (Mobile Money) |
| **Notifications** | Moyenne (Firebase) |
| **Profil** | Moyenne (User management) |
| **Maps** | Basse (Google Maps) |

---

## 🎨 Design System

### Material 3 Theme

```dart
// Primary Color: Blue (seed color)
// Surface: White/Light gray
// Accent: Red (for favoris/important)
// Error: Red
// Font: Roboto (default)
```

### Multi-Language Support

- **UI:** Français (labels, messages, validation)
- **Code:** English (class names, variables)
- **Dates:** French format "dd MMM yyyy"

---

## 📊 Data Models

### User (Multi-role)

```dart
class User {
  String id;
  String email;
  String fullName;
  String phone;
  String? profileImage;
  string? bio;
  List<UserRole> roles;  // ← MULTIPLE ROLES SUPPORT
  UserVerificationStatus verificationStatus;
  double rating;
  int reviewCount;
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;
}

enum UserRole { TENANT, LANDLORD, AGENCY, SELLER }
```

### Listing

```dart
class Listing {
  String id;
  String title;
  String description;
  ListingType type;           // RENT | SALE
  ListingStatus status;       // AVAILABLE | RENTED | SOLD | PENDING
  double price;
  String city;
  String district;
  String address;
  double latitude;
  double longitude;
  int bedrooms;
  int bathrooms;
  double surfaceArea;
  List<String> imageUrls;
  List<String> amenities;
  String ownerId;
  String ownerName;
  String? ownerImage;
  double ownerRating;
  bool isVerified;
  int views;
  int favorites;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Message & Conversation

```dart
class Message {
  String id;
  String conversationId;
  String senderId;
  String senderName;
  String? senderImage;
  String content;
  String? imageUrl;
  bool isRead;
  DateTime timestamp;
}

class Conversation {
  String id;
  List<String> participantIds;
  List<String> participantNames;
  DateTime? lastMessageAt;
  String? lastMessage;
  int unreadCount;
}
```

### Transaction

```dart
class Transaction {
  String id;
  String userId;
  String? listingId;
  double amount;
  String currency;              // Fc, USD
  String provider;              // Orange Money, Airtel, M-Pesa
  TransactionStatus status;     // PENDING, SUCCESS, FAILED
  String? referenceNumber;
  String? failureReason;
  DateTime createdAt;
  DateTime? completedAt;
}
```

---

## 🔐 Authentication Flow

```
1. USER REGISTRATION
   ┌─────────────────────────────────────┐
   │ RegisterScreen                      │
   │ - Collect: name, email, phone, role │
   │ - Validate form                     │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ AuthService.register()              │
   │ - Call Supabase Auth.signUp()       │
   │ - Create user profile in DB         │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ AuthNotifier (Riverpod)             │
   │ - Update state → AsyncValue.data    │
   │ - Store JWT token                   │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ GoRouter redirect                   │
   │ - Detect isAuthenticated = true     │
   │ - Navigate to /home                 │
   └─────────────────────────────────────┘

2. USER LOGIN
   ┌─────────────────────────────────────┐
   │ LoginScreen                         │
   │ - Input: email, password            │
   │ - Validate                          │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ AuthService.login()                 │
   │ - Call Supabase Auth.signIn()       │
   │ - Fetch user profile                │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ AuthNotifier                        │
   │ - Update state with user            │
   │ - Cache JWT                         │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ ref.listen() triggers redirect      │
   │ - Navigate /login → /home           │
   └─────────────────────────────────────┘

3. USER LOGOUT
   ┌─────────────────────────────────────┐
   │ AuthService.logout()                │
   │ - Call Supabase Auth.signOut()      │
   │ - Clear JWT token                   │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ AuthNotifier                        │
   │ - Update state → null (no user)     │
   └─────────────────────────────────────┘
                    ↓
   ┌─────────────────────────────────────┐
   │ GoRouter redirect                   │
   │ - Detect isAuthenticated = false    │
   │ - Navigate to /login                │
   └─────────────────────────────────────┘
```

---

## 🔄 Riverpod State Flow

```
User Action (e.g., login click)
    ↓
ref.read(authProvider.notifier).login(email, pwd)
    ↓
AuthNotifier.login()
    ↓
state = const AsyncValue.loading()  [UI shows loading spinner]
    ↓
AuthService.login(email, pwd)       [Call Supabase]
    ↓
Success → state = AsyncValue.data(user)  [UI shows home]
Failure → state = AsyncValue.error(e)    [UI shows error]
    ↓
ref.listen(authProvider) triggers GoRouter redirect
    ↓
Navigation happens automatically
```

---

## 🌍 Database Schema (Supabase PostgreSQL)

### Tables

```sql
users
├── id (UUID, primary key)
├── email (text, unique)
├── full_name, phone, roles[]
├── verification_status, rating
└── created_at, updated_at

listings
├── id (UUID, primary key)
├── title, description, type, status
├── price, city, district, address
├── bedrooms, bathrooms, surface_area
├── image_urls[], amenities[]
├── owner_id (foreign key) → users
├── views, favorites
└── created_at, updated_at

conversations
├── id (UUID)
├── participant_ids[], participant_names[]
├── last_message_at, last_message
└── created_at

messages
├── id (UUID)
├── conversation_id (foreign key)
├── sender_id (foreign key)
├── content, image_url, is_read
└── timestamp

transactions
├── id (UUID)
├── user_id, listing_id (foreign keys)
├── amount, currency, provider
├── status, reference_number
└── created_at, completed_at

favorites
├── id (UUID)
├── user_id (foreign key)
├── listing_id (foreign key)
├── UNIQUE(user_id, listing_id)
└── created_at
```

### RLS (Row Level Security)

```sql
-- Users can only see/edit their own data
CREATE POLICY "users_see_own_data" 
ON users USING (auth.uid() = id);

-- Users can see public listings but only edit owner's
CREATE POLICY "listings_public_read"
ON listings FOR SELECT USING (true);

CREATE POLICY "listings_owner_edit"
ON listings FOR UPDATE USING (auth.uid() = owner_id);

-- Messages visible to conversation participants
CREATE POLICY "messages_visible_to_participants"
ON messages FOR SELECT
USING (conversation_id IN (
  SELECT id FROM conversations 
  WHERE auth.uid() = ANY(participant_ids)
));
```

---

## 🛠️ Development Workflow

### Per Feature Workflow

```
1. Design
   └─ Sketch screens, data flow

2. Backend
   └─ Create Supabase tables + RLS

3. Service Layer
   └─ Create [Feature]Service with API methods

4. State (Riverpod)
   └─ Create [Feature]Notifier + providers

5. UI Screens
   └─ Create ConsumerWidget screens
   └─ Integrate providers

6. Routes
   └─ Add route to router.dart

7. Test
   └─ Manual + unit tests

8. Documentation
   └─ Update patterns/guides
```

### Commands Workflow

```bash
# Setup
flutter pub get
flutter clean

# Development
flutter run                              # Hot reload ready
dart format lib/                     # Auto-format before commit
dart analyze lib/                        # Check errors

# Testing
flutter test                             # Run tests

# Building
flutter build apk --release         # Android
flutter build ios --release             # iOS
```

---

## 📈 Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| **App Start** | < 3s | TBD |
| **Screen Transition** | < 500ms | TBD |
| **List Scroll** | 60 FPS | TBD |
| **API Response** | < 2s | TBD |
| **Cache Hit Rate** | > 80% | TBD |
| **Memory** | < 100MB | TBD |

---

## 🔒 Security Considerations

### ✅ Implemented

- JWT tokens via Supabase Auth
- HTTPS only
- Passwords min 6 chars
- RLS on all tables

### ⏳ To Implement

- Refresh token rotation
- Device fingerprinting
- 2FA (future)
- Encryption at rest (Supabase)

---

## 🌐 Deployment Checklist

### Pre-deployment

- [ ] All tests passing
- [ ] No console errors
- [ ] Lint clean (`dart analyze lib/`)
- [ ] Supabase credentials configured
- [ ] Firebase credentials configured
- [ ] Google Maps API key configured

### Android

- [ ] Sign APK
- [ ] Version bump in pubspec.yaml
- [ ] Upload to Play Store

### iOS

- [ ] Build IPA
- [ ] Code sign with certificate
- [ ] Version bump
- [ ] Upload to App Store

---

## 📞 Quick Reference Links

| Need | Resource |
|------|----------|
| 🎯 Architecture | [PATTERNS_AND_BEST_PRACTICES.md](PATTERNS_AND_BEST_PRACTICES.md#2-architecture-clean) |
| 🚀 New Feature | [EXTENSIBILITY_GUIDE.md](EXTENSIBILITY_GUIDE.md) |
| 🐛 Error | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| ⚡ Commands | [QUICK_START_COMMANDS.md](QUICK_START_COMMANDS.md) |
| 📚 Docs Index | [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) |

---

## ✨ What Makes BAILCONNECT Special

1. **Multi-role System** - Users can be Tenant AND Landlord
2. **DRC Context** - Prices in Fc, phone format +243
3. **Clean Architecture** - Scalable & testable
4. **Riverpod Reactive** - Modern state management
5. **Open Source Ready** - Well documented for community

---

**Document Version:** 1.0  
**Created:** 2026-03-25  
**Technology:** Flutter 3.x + Supabase + Riverpod  
**Status:** ✅ Production-Ready MVP
