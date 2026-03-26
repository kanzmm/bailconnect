import '../../core/constants/enums.dart';

/// Modèle Listing dans le domaine
class Listing {
  final String id;
  final String title;
  final String description;
  final ListingType type; // RENT ou SALE
  final ListingStatus status;
  final double price; // Prix de location ou achat
  final String city;
  final String district;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int bedrooms;
  final int bathrooms;
  final double surfaceArea; // m²
  final List<String> imageUrls;
  final List<String> amenities;
  final String ownerId;
  final String? ownerName;
  final String? ownerImage;
  final double? ownerRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final int views;
  final int favorites;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.price,
    required this.city,
    required this.district,
    this.address,
    this.latitude,
    this.longitude,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.surfaceArea = 0,
    required this.imageUrls,
    required this.amenities,
    required this.ownerId,
    this.ownerName,
    this.ownerImage,
    this.ownerRating,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.views = 0,
    this.favorites = 0,
  });

  String get displayPrice => price.toString();

  bool get isAvailable => status == ListingStatus.available;

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    ListingType? type,
    ListingStatus? status,
    double? price,
    String? city,
    String? district,
    String? address,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    double? surfaceArea,
    List<String>? imageUrls,
    List<String>? amenities,
    String? ownerId,
    String? ownerName,
    String? ownerImage,
    double? ownerRating,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    int? views,
    int? favorites,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      surfaceArea: surfaceArea ?? this.surfaceArea,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerImage: ownerImage ?? this.ownerImage,
      ownerRating: ownerRating ?? this.ownerRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Listing && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
