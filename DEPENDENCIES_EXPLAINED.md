# 📚 Dépendances Expliquées

Documentation complète de chaque dépendance utilisée dans BAILCONNECT.

---

## 📦 Dépendances Principales

### Core Flutter

| Package | Version | Rôle | Utilisation |
|---------|---------|------|-------------|
| **flutter** | 3.10.8+ | Framework GUI | Construire l'app (automatique) |
| **cupertino_icons** | ^1.0.0 | Icons iOS | Icônes Material & iOS |

---

## 🎯 State Management

### **flutter_riverpod** | ^2.4.0

**Rôle:** State management et Dependency Injection

**Concepts clés:**
- `Provider` - Lecture seule (immutable)
- `StateProvider` - État mutable simple
- `StateNotifierProvider` - État complexe avec logique
- `FutureProvider` - Async operations (API calls)
- `AsyncValue<T>` - Représente loading, error, data

**Exemple:**
```dart
// Provider immutable
final userProvider = Provider<User>((ref) => User());

// State mutable
final counterProvider = StateProvider<int>((ref) => 0);

// Async avec logique
final userListProvider = StateNotifierProvider<UserNotifier, AsyncValue<List<User>>>((ref) {
  return UserNotifier(ref);
});
```

**Avantages:**
✅ Reactive UI updates  
✅ Caching automatique  
✅ Testable  
✅ Scalable  

**Quand utiliser:**
- ✅ Authentification globale
- ✅ Liste d'annonces (state + async)
- ✅ Profil utilisateur
- ❌ State local d'un widget (utiliser StatefulWidget)

---

## 🛣️ Navigation

### **go_router** | ^13.0.0

**Rôle:** Navigation déclarative avec paramètres et deep linking

**Concepts clés:**
- `GoRoute` - Déclare une route
- `GoRouter.go()` - Navigate imperatif
- `context.push()` - Navigate avec stack
- `redirect` - Logique auth/permissions
- Paramètres: `/listing/:id` → `state.pathParameters['id']`

**Exemple:**
```dart
GoRoute(
  path: '/listing/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ListingDetailScreen(id: id);
  },
)

// Navigate
context.go('/listing/123')
```

**Avantages:**
✅ Deep linking natif  
✅ Web URL-like routing  
✅ Auth redirect automatique  
✅ Paramètres typés possible  

**Quand utiliser:**
- ✅ Toute navigation dans l'app
- ✅ Protected routes (auth)
- ✅ Deep links depuis notifications
- ❌ Simple show/hide (utiliser showDialog)

---

## 🔐 Backend & Auth

### **supabase_flutter** | ^1.10.0

**Rôle:** Backend as a Service - Auth, Database, Storage, Realtime

**Composants:**
```dart
// Auth
SupabaseClient.auth.signUpWithPassword()
SupabaseClient.auth.signInWithPassword()
SupabaseClient.auth.signOut()

// Database
SupabaseClient.from('table').select('*')
SupabaseClient.from('table').insert(data)

// Storage
SupabaseClient.storage.from('bucket').upload()

// Realtime
SupabaseClient.from('table').on(...)
```

**Utilisation dans le projet:**
- `lib/core/config/supabase_config.dart` - Initialization
- `lib/core/providers/auth_service.dart` - Auth logic
- `lib/core/providers/listing_provider.dart` - Listings CRUD

**Avantages:**
✅ PostgreSQL managé  
✅ Auth email/password  
✅ JWT tokens  
✅ RLS (Row Level Security)  
✅ Realtime subscriptions  

**Quand utiliser:**
- ✅ User authentication
- ✅ Toda storge et CRUD
- ✅ Realtime updates (messages)
- ✅ File uploads

---

### **http** | ^1.1.0

**Rôle:** HTTP client pour appels API

**Exemple:**
```dart
final response = await http.get(Uri.parse('https://api.example.com'));
```

**Status:** À évaluer  
(Supabase gère généralement les appels via client lui-même)

---

## 🎨 UI & Styling

### **cached_network_image** | ^3.3.0

**Rôle:** Image loading avec caching (efficace)

**Exemple:**
```dart
CachedNetworkImage(
  imageUrl: 'https://cdn.example.com/image.jpg',
  placeholder: (context, url) => LoadingWidget(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**Avantages:**
✅ Caching automatique  
✅ Placeholder pendant load  
✅ Error widget  
✅ Optimisé pour perfs  

**Quand utiliser:**
- ✅ Images d'annonces
- ✅ Images de profils
- ❌ Icônes locales (utiliser Icon directement)

---

## 📍 Location & Maps

### **google_maps_flutter** | ^2.5.0

**Rôle:** Affichage de cartes Google Maps

**Exemple:**
```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(-11.6797, 27.1825), // Lubumbashi
    zoom: 12,
  ),
  markers: {
    Marker(
      markerId: MarkerId('1'),
      position: LatLng(-11.68, 27.18),
    ),
  },
)
```

**Status:** ⏳ À implémenter  
(Feature 6 du plan)

**Prérequis:**
- API Key Google Maps Platform
- Configurer dans `android/app/src/main/AndroidManifest.xml`
- Configurer dans `ios/Runner/Info.plist`

---

### **geolocator** | ^10.0.0

**Rôle:** Accès GPS et localisation utilisateur

**Exemple:**
```dart
final position = await Geolocator.getCurrentPosition();
final latitude = position.latitude;
final longitude = position.longitude;
```

**Permissions requises:**
- Android: `android.permission.ACCESS_FINE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`

---

## 📱 Media & Images

### **image_picker** | ^1.0.0

**Rôle:** Sélectionner images depuis galerie/caméra

**Exemple:**
```dart
final ImagePicker _picker = ImagePicker();
final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
```

**Status:** ⏳ À implémenter  
(Nécessaire pour créer annonces)

---

## 🔔 Notifications

### **firebase_messaging** | ^14.6.0

**Rôle:** Push notifications via Firebase Cloud Messaging

**Configuration requise:**
1. Firebase project creation
2. Service account JSON
3. `google-services.json` (Android)
4. `GoogleService-Info.plist` (iOS)

**Exemple:**
```dart
FirebaseMessaging.instance.getToken()
  .then((token) => saveTokenToSupabase(token));

FirebaseMessaging.onMessage.listen((message) {
  showNotification(message);
});
```

**Status:** ⏳ À implémenter  
(Feature 7 du plan)

---

## ⚙️ Utilities

### **intl** | ^0.19.0

**Rôle:** Internationalization (i18n) et formatting

**Exemple:**
```dart
import 'package:intl/intl.dart';

// Format prix
final formatted = NumberFormat('#,###', 'fr_FR').format(1500); // 1 500

// Format date
final date = DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.now());
// Output: 25 jnv 2026
```

**Utilisation dans le projet:**
- `lib/core/utils/format_helper.dart` - Prix, dates, etc.

**Avantages:**
✅ Locale-aware formatting  
✅ Multiple languages  
✅ Currency handling  

---

### **timeago** | ^3.4.0

**Rôle:** Formatage de durées ("Il y a Xh")

**Exemple:**
```dart
import 'package:timeago/timeago.dart' as timeago;

timeago.format(DateTime.now().subtract(Duration(hours: 2)));
// Output: "2 hours ago"

// Avec locale français
timeago.setLocaleMessages('fr', FrMessages());
timeago.format(dateTime, locale: 'fr');
// Output: Il y a 2h
```

**Utilisation dans le projet:**
- Messages timestamps (chat, dernière mise à jour)

---

### **url_launcher** | ^6.1.0

**Rôle:** Ouvrir URLs, appeler, envoyer SMS

**Exemple:**
```dart
// Ouvrir URL
await launchUrl(Uri.parse('https://example.com'));

// Appeler
await launchUrl(Uri(scheme: 'tel', path: '0123456789'));

// SMS
await launchUrl(Uri(scheme: 'sms', path: '0123456789'));

// Email
await launchUrl(Uri(scheme: 'mailto', path: 'user@example.com'));
```

**Utilisation potentielle:**
- "Appeler propriétaire" → launchUrl(tel:)
- "Envoyer SMS" → launchUrl(sms:)

---

### **shared_preferences** | ^2.2.0

**Rôle:** Persistent local storage simple (key-value)

**Exemple:**
```dart
final prefs = await SharedPreferences.getInstance();

// Sauvegarder
await prefs.setString('theme', 'dark');

// Charger
final theme = prefs.getString('theme') ?? 'light';

// Supprimer
await prefs.remove('theme');
```

**Utilisation suggérée:**
- Sauvegarder préférences utilisateur
- Cache token JWT temporaire
- Récemment visité

**Limitation:** Pas for gros data (< 1MB)

---

### **flutter_secure_storage** | ^9.0.0

**Rôle:** Stockage sécurisé des données sensibles

**Exemple:**
```dart
final storage = FlutterSecureStorage();

// Sauvegarder token
await storage.write(key: 'jwt_token', value: token);

// Charger
final token = await storage.read(key: 'jwt_token');

// Supprimer
await storage.delete(key: 'jwt_token');
```

**Avantage sur SharedPreferences:**
✅ Chiffré  
✅ Sécurisé (Keychain iOS, Keystore Android)  
✅ Pour tokens, passwords  

**Utilisation suggérée:**
- Stocker JWT token
- Stocker credentials (Recommandé contre pwd locaux)

---

### **web_socket_channel** | ^2.4.0

**Rôle:** WebSocket pour communication bidirectionnelle temps réel

**Exemple:**
```dart
final channel = IOWebSocketChannel.connect('wss://example.com/chat');

// Envoyer
channel.sink.add(jsonEncode({'message': 'Hello'}));

// Écouter
channel.stream.listen((message) {
  print('Message reçu: $message');
});

// Fermer
await channel.sink.close();
```

**Status:** ⏳ À implémenter  
(Pour chat features Supabase Realtime)

**Alternative:**
Supabase a du realtime intégré, donc web_socket_channel peut être optionnel.

---

## 🧪 Dev & Testing

### **flutter_test** (inclus)

**Rôle:** Framework testing pour widgets et unit tests

**Exemple:**
```dart
testWidgets('LoginScreen shows error', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));
  await tester.enterText(find.byType(TextField), 'invalid');
  expect(find.text('Email invalide'), findsOneWidget);
});
```

---

## 📊 Dépendances par Feature

| Feature | Packages Utilisés |
|---------|-------------------|
| **Auth** | riverpod, supabase_flutter, flutter_secure_storage |
| **Listings** | riverpod, supabase_flutter, cached_network_image, google_maps_flutter |
| **Chat** | supabase_flutter, web_socket_channel, intl |
| **Paiements** | http (optionnel), intl |
| **Notifications** | firebase_messaging |
| **UI Générale** | cupertino_icons, intl, timeago |
| **Utils** | url_launcher, shared_preferences |

---

## ⚖️ Décisions d'Architecture

### Pourquoi Riverpod et pas Provider?

```
Provider (ancien)  →  Riverpod (nouveau)
- Legacy API       →  ✨ Modern API
- Crashes runtime  →  🛡️ Type-safe compile-time
- StatefulWidget   →  ConsumerWidget
```

**Choix:** Riverpod (best practices actuellesindre)

---

### Pourquoi GoRouter et pas Navigator?

```
Navigator (legacy)     →  GoRouter (moderne)
- Imperial API         →  Déclaratif  
- Pas de deep linking  →  Deep links natifs
- Pas de redirects     →  Auth redirects simples
```

**Choix:** GoRouter (web-first routing)

---

### Pourquoi Supabase et pas Firebase?

```
Firebase        →  Supabase
- Propriétaire  →  Open Source (PostgreSQL)
- $$$ cher      →  Plus économique
- Auth seulement→  Auth + DB + Storage
```

**Choix:** Supabase (PostgreSQL, RLS, DRC context)

---

## 🚀 Dépendances Futures (À considérer)

| Package | Usage | Priorité |
|---------|-------|----------|
| **awesome_notifications** | Local notifications | Moyenne |
| **hive** | Local DB (gros data) | Basse |
| **get_it** | Service locator | Basse |
| **dartz** | Functional programming | Basse |
| **equatable** | Value equality | Basse |
| **freezed** | Code generation | Basse |
| **json_serializable** | JSON parsing | Moyenne |

---

## ✅ Quick Reference

### Import Patterns

```dart
// Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation
import 'package:go_router/go_router.dart';

// Backend
import 'package:supabase_flutter/supabase_flutter.dart';

// UI
import 'package:cached_network_image/cached_network_image.dart';

// Utils
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
```

### Pub.dev Commands

```bash
# Chercher packages
pub.dev

# Installer
flutter pub add package_name

# Mettre à jour
flutter pub upgrade

# Vérifier versions
flutter pub outdated
```

---

**Version:** 1.0  
**Créé:** 2026-03-25  
**Maintenance:** Mise à jour avec nouvelles dépendances

