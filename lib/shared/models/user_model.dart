import '../../core/constants/enums.dart';

/// Modèle User dans le domaine
class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? profileImage;
  final String? bio;
  final List<UserRole> roles; // Multi-rôles
  final UserVerificationStatus verificationStatus;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.profileImage,
    this.bio,
    required this.roles,
    this.verificationStatus = UserVerificationStatus.unverified,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Copywith
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? profileImage,
    String? bio,
    List<UserRole>? roles,
    UserVerificationStatus? verificationStatus,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      roles: roles ?? this.roles,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper
  bool hasRole(UserRole role) => roles.contains(role);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
