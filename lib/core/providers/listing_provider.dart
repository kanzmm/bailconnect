import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/listing_model.dart';
import '../../core/constants/enums.dart';
import '../config/supabase_config.dart';

/// Service Listings
class ListingService {
  // Récupérer toutes les annonces avec filtrage
  Future<List<Listing>> searchListings({
    String? city,
    String? district,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;
      var query = SupabaseConfig.client.listings.select().eq(
        'status',
        'active',
      );

      // Appliquer les filtres conditionnels avant range
      if (city != null) query = query.filter('city', 'eq', city);
      if (type != null) query = query.filter('type', 'eq', type.name);
      if (minPrice != null) query = query.filter('price', 'gte', minPrice);
      if (maxPrice != null) query = query.filter('price', 'lte', maxPrice);

      // Appliquer la pagination à la fin
      final response = await query.range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => _mapToListing(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur searchListings: $e');
      return [];
    }
  }

  Future<Listing?> getListingById(String id) async {
    try {
      final response = await SupabaseConfig.client.listings
          .select()
          .eq('id', id)
          .single();
      return _mapToListing(response);
    } catch (e) {
      return null;
    }
  }

  Future<Listing> createListing({
    required String title,
    required String description,
    required ListingType type,
    required double price,
    required String city,
    required String district,
    String? address,
    double? latitude,
    double? longitude,
    int bedrooms = 0,
    int bathrooms = 0,
    double surfaceArea = 0,
    List<String> imageUrls = const [],
    List<String> amenities = const [],
  }) async {
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non authentifié');

      final response = await SupabaseConfig.client.listings
          .insert({
            'owner_id': userId,
            'title': title,
            'description': description,
            'type': type.name,
            'price': price,
            'city': city,
            'district': district,
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'bedrooms': bedrooms,
            'bathrooms': bathrooms,
            'surface_area': surfaceArea,
            'image_urls': imageUrls,
            'amenities': amenities,
            'status': 'active',
          })
          .select()
          .single();

      return _mapToListing(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur création annonce: $e');
    }
  }

  Future<void> updateListing({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await SupabaseConfig.client.listings.update(updates).eq('id', id);
    } catch (e) {
      throw Exception('Erreur mise à jour annonce: $e');
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await SupabaseConfig.client.listings.delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur suppression annonce: $e');
    }
  }

  Future<List<Listing>> getUserListings(String userId) async {
    try {
      final response = await SupabaseConfig.client.listings.select().eq(
        'owner_id',
        userId,
      );

      return (response as List)
          .map((json) => _mapToListing(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur getUserListings: $e');
      return [];
    }
  }

  Listing _mapToListing(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _parseListingType(json['type'] as String?),
      status: _parseListingStatus(json['status'] as String?),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      surfaceArea: (json['surface_area'] as num?)?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      ownerId: json['owner_id'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      ownerImage: json['owner_image'] as String?,
      ownerRating: (json['owner_rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      favorites: json['favorites'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  ListingType _parseListingType(String? value) {
    if (value == null) return ListingType.rent;
    try {
      return ListingType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return ListingType.rent;
    }
  }

  ListingStatus _parseListingStatus(String? value) {
    if (value == null) return ListingStatus.available;
    try {
      return ListingStatus.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return ListingStatus.available;
    }
  }
}

/// Notifier pour les listings
class ListingNotifier extends StateNotifier<AsyncValue<List<Listing>>> {
  final ListingService _service = ListingService();

  ListingNotifier() : super(const AsyncValue.loading()) {
    _loadListings();
  }

  Future<void> _loadListings() async {
    state = const AsyncValue.loading();
    try {
      final listings = await _service.searchListings();
      state = AsyncValue.data(listings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchListings({
    String? city,
    String? district,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
  }) async {
    state = const AsyncValue.loading();
    try {
      final listings = await _service.searchListings(
        city: city,
        district: district,
        type: type,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      state = AsyncValue.data(listings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createListing({
    required String title,
    required String description,
    required ListingType type,
    required double price,
    required String city,
    required String district,
    String? address,
    double? latitude,
    double? longitude,
    int bedrooms = 0,
    int bathrooms = 0,
    double surfaceArea = 0,
    List<String> imageUrls = const [],
    List<String> amenities = const [],
  }) async {
    try {
      final listing = await _service.createListing(
        title: title,
        description: description,
        type: type,
        price: price,
        city: city,
        district: district,
        address: address,
        latitude: latitude,
        longitude: longitude,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        surfaceArea: surfaceArea,
        imageUrls: imageUrls,
        amenities: amenities,
      );

      final currentListings = state.value ?? [];
      state = AsyncValue.data([...currentListings, listing]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshListings() async {
    await _loadListings();
  }
}

/// Provider pour les listings
final listingProvider =
    StateNotifierProvider<ListingNotifier, AsyncValue<List<Listing>>>((ref) {
      return ListingNotifier();
    });

/// Provider pour les listings filtrés
final searchListingsProvider =
    FutureProvider.family<List<Listing>, Map<String, dynamic>>((ref, filters) {
      final service = ListingService();
      return service.searchListings(
        city: filters['city'] as String?,
        district: filters['district'] as String?,
        type: filters['type'] as ListingType?,
        minPrice: filters['minPrice'] as double?,
        maxPrice: filters['maxPrice'] as double?,
      );
    });

/// Provider pour une annonce spécifique
final listingDetailProvider = FutureProvider.family<Listing?, String>((
  ref,
  id,
) {
  final service = ListingService();
  return service.getListingById(id);
});
