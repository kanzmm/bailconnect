# 🛠️ Patterns & Bonnes Pratiques - BAILCONNECT

Ce document couvre les patterns utilisés dans le projet et comment les appliquer.

---

## 1. État avec Riverpod

### Pattern: StateNotifier pour état mutable

```dart
// ✅ BON: Utiliser StateNotifier pour états complexes
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this.ref) : super(const AsyncValue.loading());
  
  final Ref ref;
  
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      AuthService.instance.login(email, password)
    );
  }
}

// ❌ MAUVAIS: Utiliser Consumer directement
// (Pas de séparation logique)
```

### Pattern: FutureProvider pour données asynchrones READ-ONLY

```dart
// ✅ BON: Utiliser FutureProvider pour une requête unique
final listingDetailProvider = FutureProvider.family<Listing, String>((ref, id) async {
  return await ListingService.instance.getListingById(id);
});

// Utilisation:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final listing = ref.watch(listingDetailProvider(id));
  return listing.when(
    loading: () => const LoadingWidget(),
    error: (err, stack) => ErrorWidget(error: err),
    data: (listing) => ListingContent(listing: listing),
  );
}
```

### Pattern: Sélecteurs pour dériver état

```dart
// ✅ BON: Créer des sélecteurs pour logique dérivée
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

final currentRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).maybeWhen(
    data: (user) => user?.roles.first,
    orElse: () => null,
  );
});

final hasRoleProvider = Provider.family<bool, UserRole>((ref, role) {
  return ref.watch(authProvider).maybeWhen(
    data: (user) => user?.hasRole(role) ?? false,
    orElse: () => false,
  );
});
```

---

## 2. Architecture Clean

### Structure par Feature

```
feature_name/
├── data/
│   ├── datasources/          # Appels API/DB
│   │   ├── local_datasource.dart
│   │   └── remote_datasource.dart
│   ├── models/               # DTO avec fromJson/toJson
│   │   └── listing_model.dart
│   └── repositories/         # Implémentation repositories
│       └── listing_repository_impl.dart
├── domain/
│   ├── entities/             # Modèles métier purs
│   │   └── listing.dart
│   ├── repositories/         # Contrats (abstraits)
│   │   └── listing_repository.dart
│   └── usecases/             # Logique métier
│       ├── get_listings.dart
│       └── search_listings.dart
└── presentation/
    ├── screens/
    ├── widgets/
    ├── providers/            # Riverpod intégration
    └── pages/
```

### Exemple: Implémentation d'un repository

```dart
// ❌ MAUVAIS: Logique métier dispersée
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = supabase.from('listings').select();
    // ...
  }
}

// ✅ BON: Via repository & provider
class ListingRepositoryImpl implements ListingRepository {
  final SupabaseClient _client;
  
  @override
  Future<List<Listing>> searchListings({
    required String city,
    int? maxPrice,
  }) async {
    try {
      var query = _client.from('listings').select('*');
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      final response = await query.eq('city', city);
      return (response as List)
        .map((json) => Listing.fromJson(json))
        .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

// Dans le provider:
final listingProvider = StateNotifierProvider<
  ListingNotifier, 
  AsyncValue<List<Listing>>
>((ref) {
  return ListingNotifier(ListingRepositoryImpl(supabase));
});

// Dans le screen:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final listings = ref.watch(listingProvider);
  return listings.when(
    data: (list) => ListingList(listings: list),
    loading: () => const LoadingWidget(),
    error: (err, stack) => ErrorWidget(error: err),
  );
}
```

---

## 3. Validation & Erreurs

### Pattern: Result<T> pour Success/Failure

```dart
// ✅ BON: Utiliser Result pattern
abstract class Result<T> {
  Success<T> _asSuccess() => this as Success<T>;
  Failure _asFailure() => this as Failure;
}

class Success<T> implements Result<T> {
  final T data;
  Success(this.data);
}

class Failure implements Result<Never> {
  final String message;
  final Exception? exception;
  Failure(this.message, [this.exception]);
}

// Utilisation:
Future<Result<User>> login(String email, String password) async {
  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return Success(User.fromJson(response.user!.toJson()));
  } on AuthException catch (e) {
    return Failure('Erreur auth: ${e.message}', e);
  } catch (e) {
    return Failure('Erreur serveur', Exception(e.toString()));
  }
}

// Gestion:
final result = await AuthService.instance.login(email, password);
if (result is Success<User>) {
  // Succès
  final user = result._asSuccess().data;
} else if (result is Failure) {
  // Erreur
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result._asFailure().message))
  );
}
```

### Pattern: Validation de formulaires

```dart
// ✅ BON: Utiliser GlobalKey + validators
class RegisterForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) => Validator.validateEmail(value),
            decoration: InputDecoration(labelText: 'Email'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ref.read(authProvider.notifier).register(
                  email: _emailController.text,
                );
              }
            },
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }
}
```

---

## 4. Navigation

### Pattern: GoRouter avec redirects

```dart
// ✅ BON: Redirects pour logique authentification
final goRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  
  return GoRouter(
    initialLocation: isAuthenticated ? '/home' : '/login',
    debugLogDiagnostics: !kReleaseMode,
    redirect: (context, state) {
      if (!isAuthenticated && state.location != '/login' && state.location != '/register') {
        return '/login';
      }
      if (isAuthenticated && (state.location == '/login' || state.location == '/register')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) => ListingDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
```

### Pattern: Named routes avec params

```dart
// ✅ BON: Utiliser les paramètres GoRouter
// Navigation:
context.go('/listing/${listing.id}');

// Récupération dans le screen:
class ListingDetailScreen extends ConsumerWidget {
  final String id;
  
  const ListingDetailScreen({required this.id});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingDetailProvider(id));
    // ...
  }
}
```

---

## 5. Formatage & Localisation

### Pattern: Helpers centralisés

```dart
// ✅ BON: Utiliser des fonctions de formatage
class FormatHelper {
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return 'Fc ${formatter.format(price.toInt())}';
  }
  
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }
  
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    
    return formatDate(date);
  }
}

// Utilisation dans UI:
Text(FormatHelper.formatPrice(1500.0))  // Fc 1 500
```

---

## 6. Widgets Réutilisables

### Pattern: StatelessWidget paramétrisé

```dart
// ✅ BON: Créer des widgets génériques
class LoadingWidget extends StatelessWidget {
  final String message;
  
  const LoadingWidget({this.message = 'Chargement...'});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  
  const ErrorWidget({required this.error, this.onRetry});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Erreur: $error'),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}

// Utilisation:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final data = ref.watch(someProvider);
  return data.when(
    loading: () => const LoadingWidget(),
    error: (err, _) => ErrorWidget(error: err),
    data: (data) => ContentWidget(data: data),
  );
}
```

---

## 7. Gestion d'Images

### Pattern: Images avec fallback

```dart
// ✅ BON: Gérer les images avec caching et fallback
class ListingImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  
  const ListingImage({
    this.imageUrl,
    this.height = 200,
  });
  
  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: Colors.grey[300],
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (_, __, ___) => Container(
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
```

---

## 8. Async Operations à l'écran

### Pattern: ConsumerWidget + ref.watch

```dart
// ✅ BON: Utiliser ConsumerWidget pour accès au Riverpod
class HomeScreen extends ConsumerWidget {
  const HomeScreen();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider (rebuilds on change)
    final listings = ref.watch(listingProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Annonces')),
      body: listings.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorWidget(
          error: error,
          onRetry: () => ref.refresh(listingProvider),
        ),
        data: (listings) => ListView.builder(
          itemCount: listings.length,
          itemBuilder: (context, index) {
            return ListingCard(listing: listings[index]);
          },
        ),
      ),
    );
  }
}

// ❌ MAUVAIS: Utiliser StatefulWidget + setState
// (Plus verbeux, pas d'avantages)
```

### Pattern: Listener pour effets side-effect

```dart
// ✅ BON: Utiliser ref.listen pour naviguer après action
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter changements d'authentification
    ref.listen(authProvider, (previous, next) {
      next.maybeWhen(
        data: (user) {
          if (user != null) {
            // Utilisateur authentifié, naviguer
            context.go('/home');
          }
        },
        error: (error, stack) {
          // Afficher erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
        orElse: () {},
      );
    });
    
    return Scaffold(
      # ... formulaire login
    );
  }
}
```

---

## 9. Testing

### Unit Test Pattern

```dart
// ✅ BON: Tester services isolés
void main() {
  group('AuthService', () {
    test('login returns user on valid credentials', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      // Act
      final result = await AuthService.instance.login(email, password);
      
      // Assert
      expect(result, isA<Success<User>>());
    });
    
    test('login returns failure on wrong password', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';
      
      // Act
      final result = await AuthService.instance.login(email, password);
      
      // Assert
      expect(result, isA<Failure>());
    });
  });
}
```

### Widget Test Pattern

```dart
// ✅ BON: Tester widgets avec Riverpod
void main() {
  group('LoginScreen', () {
    testWidgets('shows error on invalid email', (tester) async {
      // Build widget
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(home: LoginScreen()),
        ).listen(_),
      );
      
      // Enter invalid email
      await tester.enterText(find.byType(TextField).first, 'invalid');
      await tester.pumpWidget(SizedBox()); // Rebuild
      
      // Expect error
      expect(find.text('Email invalide'), findsOneWidget);
    });
  });
}
```

---

## 10. Dépendances & Injection

### Pattern: Service Locator (GetIt)

```dart
// À considérer pour phases suivantes
// Pour MVP, les singletons statiques suffisent

class AuthService {
  static final AuthService _instance = AuthService._();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._();
  
  // Méthodes...
}

// Utilisation:
final authService = AuthService();
```

---

## ⚠️ Anti-Patterns à Éviter

| ❌ À ÉVITER | ✅ À FAIRE |
|-------------|-----------|
| Appels API dans les widgets | Utiliser des services séparés |
| setState dans StatefulWidget | Utiliser Riverpod StateNotifier |
| Logique métier dans les screens | Créer des use cases |
| Globalizer partout | Utiliser Riverpod providers |
| Doubles appels API | Cacher les résultats |
| Noms generiques (data, item) | Noms explicites (user, listing) |
| Widgets massifs | Découper en petits widgets |
| Mix de langues | Français pour UI, anglais pour code |

---

## 📚 Ressources

- [Riverpod Docs](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

