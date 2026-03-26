# 🚀 Guide d'Extensibilité - Ajouter Nouvelles Features

Comment ajouter facilement une nouvelle fonctionnalité à BAILCONNECT.

---

## Template: Nouvelle Feature en 5 Étapes

### Exemple: Ajouter "Favoris" (Wishlist)

#### Étape 1: Créer la Structure

```bash
mkdir -p lib/features/favorites/{data,domain,presentation}
mkdir -p lib/features/favorites/presentation/{screens,widgets}
mkdir -p lib/shared/models
```

#### Étape 2: Créer le Model

**Fichier: `lib/shared/models/favorite_model.dart`**

```dart
class Favorite {
  final String id;
  final String userId;
  final String listingId;
  final DateTime createdAt;
  
  Favorite({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.createdAt,
  });
  
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      listingId: json['listing_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'listing_id': listingId,
    'created_at': createdAt.toIso8601String(),
  };
  
  Favorite copyWith({
    String? id,
    String? userId,
    String? listingId,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listingId: listingId ?? this.listingId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

#### Étape 3: Créer le Service

**Fichier: `lib/core/providers/favorite_service.dart`**

```dart
class FavoriteService {
  static final FavoriteService _instance = FavoriteService._();
  
  factory FavoriteService() => _instance;
  FavoriteService._();
  
  // CRUD operations
  Future<Result<void>> addFavorite({
    required String userId,
    required String listingId,
  }) async {
    try {
      await SupabaseConfig.client.from('favorites').insert({
        'user_id': userId,
        'listing_id': listingId,
      });
      return Success(null);
    } catch (e) {
      return Failure('Erreur ajout favori: $e');
    }
  }
  
  Future<Result<void>> removeFavorite({
    required String userId,
    required String listingId,
  }) async {
    try {
      await SupabaseConfig.client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('listing_id', listingId);
      return Success(null);
    } catch (e) {
      return Failure('Erreur suppression favori: $e');
    }
  }
  
  Future<Result<List<Favorite>>> getUserFavorites(String userId) async {
    try {
      final response = await SupabaseConfig.client
        .from('favorites')
        .select('*')
        .eq('user_id', userId);
      
      final favorites = (response as List)
        .map((json) => Favorite.fromJson(json))
        .toList();
      
      return Success(favorites);
    } catch (e) {
      return Failure('Erreur récupération favoris: $e');
    }
  }
  
  Future<bool> isFavorited({
    required String userId,
    required String listingId,
  }) async {
    try {
      final response = await SupabaseConfig.client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('listing_id', listingId);
      
      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
```

#### Étape 4: Créer le Riverpod Provider

**Fichier: `lib/core/providers/favorite_provider.dart`**

```dart
final FavoriteService favoriteService = FavoriteService();

// Notifier pour gérer l'état
class FavoriteNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  FavoriteNotifier(this.ref) : super(const AsyncValue.loading());
  
  final Ref ref;
  
  Future<void> loadFavorites(String userId) async {
    state = const AsyncValue.loading();
    final result = await favoriteService.getUserFavorites(userId);
    
    state = result.maybeWhen(
      success: (favorites) => AsyncValue.data(
        favorites.map((f) => f.listingId).toSet(),
      ),
      failure: (error) => AsyncValue.error(error, StackTrace.current),
      orElse: () => const AsyncValue.data({}),
    );
  }
  
  Future<void> toggleFavorite({
    required String userId,
    required String listingId,
  }) async {
    final currentFavorites = state.maybeWhen(
      data: (favs) => favs,
      orElse: () => <String>{},
    );
    
    final isFavorited = currentFavorites.contains(listingId);
    
    // Optimistic update
    state = AsyncValue.data({
      ...currentFavorites,
      if (!isFavorited) listingId else ...[listingId],
    });
    
    // Backend call
    final result = isFavorited
      ? await favoriteService.removeFavorite(
          userId: userId,
          listingId: listingId,
        )
      : await favoriteService.addFavorite(
          userId: userId,
          listingId: listingId,
        );
    
    result.whenFail((error) {
      // Revert on error
      state = AsyncValue.data(currentFavorites);
    });
  }
}

// Providers
final favoriteProvider = StateNotifierProvider<
  FavoriteNotifier,
  AsyncValue<Set<String>>
>((ref) {
  return FavoriteNotifier(ref);
});

final isFavoritedProvider = Provider.family<bool, String>((ref, listingId) {
  return ref.watch(favoriteProvider).maybeWhen(
    data: (favorites) => favorites.contains(listingId),
    orElse: () => false,
  );
});

final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(favoriteProvider).maybeWhen(
    data: (favorites) => favorites.length,
    orElse: () => 0,
  );
});
```

#### Étape 5: Utiliser dans l'UI

**Fichier: `lib/features/favorites/presentation/favorites_screen.dart`**

```dart
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final favorites = ref.watch(favoriteProvider);
    
    return currentUser.when(
      data: (user) => favorites.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorWidget(error: error),
        data: (_) => FutureBuilder<List<Listing>>(
          future: _loadFavoritedListings(ref, user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            if (snapshot.hasError) {
              return ErrorWidget(error: snapshot.error);
            }
            
            final listings = snapshot.data ?? [];
            return ListView.builder(
              itemCount: listings.length,
              itemBuilder: (context, index) {
                return ListingCard(listing: listings[index]);
              },
            );
          },
        ),
      ),
      loading: () => const LoadingWidget(),
      error: (error, _) => ErrorWidget(error: error),
    );
  }
  
  Future<List<Listing>> _loadFavoritedListings(Ref ref, String userId) async {
    return await ListingService.instance.getFavoritedListings(userId);
  }
}

// Widget: Heart button pour favoris
class FavoriteButton extends ConsumerWidget {
  final String listingId;
  final double size;
  
  const FavoriteButton({
    required this.listingId,
    this.size = 24,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isFavorited = ref.watch(isFavoritedProvider(listingId));
    
    return currentUser.maybeWhen(
      data: (user) => user != null
        ? IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              size: size,
              color: isFavorited ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              ref.read(favoriteProvider.notifier).toggleFavorite(
                userId: user.id,
                listingId: listingId,
              );
            },
          )
        : const SizedBox.shrink(),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
```

#### Étape 6: Ajouter Route

**Modifier `lib/config/router.dart`:**

```dart
GoRoute(
  path: '/favorites',
  builder: (context, state) => const FavoritesScreen(),
),
```

#### Étape 7: Créer Supabase Table

```sql
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, listing_id)
);

-- RLS Policy
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own favorites"
ON favorites
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

---

## Checklist: Ajouter une Feature

```
Template pour ajouter n'importe quelle feature

☐ Créer dossier feature: lib/features/[feature_name]/
☐ Structure: data/, domain/, presentation/
☐ Créer model(s) dans lib/shared/models/
☐ Créer service(s) dans lib/core/providers/
☐ Créer Riverpod provider(s)
☐ Créer screen(s) en ConsumerWidget
☐ Ajouter route(s) dans router.dart
☐ Créer table(s) Supabase + RLS
☐ Tester l'intégration complète
☐ Documenter l'API dans comments
☐ Ajouter tests unitaires (optionnel MVP)
☐ Ajouter tests widgets (optionnel MVP)
```

---

## Patterns Recommandés par Feature Type

### Feature avec CRUD (Listings, Messages, etc.)

```
Model → Service → StateNotifier → Provider → Screen
```

**Exemple de flux:**
```dart
// User clicks add
onPressed: () => ref.read(myProvider.notifier).create(data)
  ↓
// Notifier appelle service
FavoriteNotifier.toggleFavorite()
  ↓
// Service hit Supabase
FavoriteService.addFavorite()
  ↓
// Update state
state = AsyncValue.data(updatedList)
  ↓
// UI rebuilds
FavoritesScreen.build()
```

### Feature avec Navigation

```
Router → Providers → Screens → Widgets
```

**Exemple de flux:**
```dart
// GoRouter navigates
context.go('/favorites')
  ↓
// New screen builds
FavoritesScreen()
  ↓
// Screen watches providers
ref.watch(favoriteProvider)
  ↓
// Data displayed
ListView(listings)
```

### Feature avec Configuration

```
Constants → Service → Provider → Widget
```

**Exemple: Theme Provider**
```
AppConstants.themes → ThemeService → themeProvider → MyApp
```

---

## Erreurs Courantes en Ajoutant une Feature

### ❌ Oublier d'ajouter la route

```dart
// ❌ MAUVAIS
// Créer screen mais oublier la route dans router.dart

// ✅ BON
GoRoute(
  path: '/favorites',
  builder: (context, state) => const FavoritesScreen(),
),
```

### ❌ Oublier ConsumerWidget

```dart
// ❌ MAUVAIS: Screen stateless normal
class FavoritesScreen extends StatelessWidget {}

// ✅ BON: Screen consumer pour Riverpod
class FavoritesScreen extends ConsumerWidget {}
```

### ❌ Ne pas gérer AsyncValue

```dart
// ❌ MAUVAIS
final favorites = ref.watch(favoriteProvider);
return ListView(children: favorites); // Crash si loading!

// ✅ BON
final favorites = ref.watch(favoriteProvider);
return favorites.when(
  loading: () => LoadingWidget(),
  error: (e, st) => ErrorWidget(error: e),
  data: (list) => ListView(children: list),
);
```

### ❌ Appel service dans build()

```dart
// ❌ MAUVAIS
@override
Widget build(BuildContext context, WidgetRef ref) {
  favoriteService.loadFavorites(); // Appelé à chaque rebuild!
}

// ✅ BON
@override
void initState() {
  super.initState();
  ref.read(favoriteProvider.notifier).loadFavorites(userId);
}
// Ou utiliser effect:
ref.listen(someProvider, (previous, next) {
  // Appelé une fois seulement
});
```

### ❌ Oublier RLS Supabase

```sql
-- ❌ MAUVAIS: Table sans RLS
CREATE TABLE favorites (...);

-- ✅ BON: RLS activé et politiques configurées
CREATE TABLE favorites (...);
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own favorites"
ON favorites USING (auth.uid() = user_id);
```

---

## Optimisation: Quand Ajouter Caching?

### Petit dataset (< 100 items)
→ Stocker en RAM avec StateNotifier

### Moyen dataset (100-1000 items)
→ Utiliser SharedPreferences + Supabase sync

### Gros dataset (> 1000 items)
→ Pagination + Lazy loading + Hive pour local cache

**Exemple avec pagination:**
```dart
final paginatedProvider = StateNotifierProvider<
  PaginatedNotifier,
  AsyncValue<List<Listing>>
>((ref) {
  return PaginatedNotifier();
});

class PaginatedNotifier extends StateNotifier<AsyncValue<List<Listing>>> {
  int _page = 0;
  static const pageSize = 20;
  
  Future<void> loadMore() async {
    // Charger page suivante
    final listings = await service.getListings(
      page: _page++,
      pageSize: pageSize,
    );
    // Append à l'état existant
    state.whenData((current) => [...current, ...listings]);
  }
}
```

---

## Testing: Template pour Feature

**Fichier: `test/features/favorites_test.dart`**

```dart
void main() {
  group('FavoriteService', () {
    test('addFavorite success', () async {
      // Arrange
      const userId = 'user-123';
      const listingId = 'listing-456';
      
      // Act
      final result = await FavoriteService().addFavorite(
        userId: userId,
        listingId: listingId,
      );
      
      // Assert
      expect(result, isA<Success>());
    });
  });
  
  group('FavoritesScreen', () {
    testWidgets('shows loading state', (tester) async {
      // Arrange & Act & Assert
    });
  });
}
```

---

## Ressources utiles

Pour créer une nouvelle feature, consulter:
1. Feature existante comme référence (listings/, chat/)
2. `PATTERNS_AND_BEST_PRACTICES.md` pour patterns
3. `TROUBLESHOOTING.md` pour dépannage
4. Docs Officiel: [Riverpod](https://riverpod.dev), [GoRouter](https://pub.dev/packages/go_router)

---

**Template créé:** 2026-03-25  
**Demiers partenaires utilisés:** Favorites, Payments  
**Feedback:** Créer une issue GitHub pour améliorations

