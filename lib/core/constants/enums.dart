// Énumérations
enum UserRole { tenant, landlord, agency, seller }

enum ListingType { rent, sale }

enum ListingStatus { available, rented, sold, pending }

enum UserVerificationStatus { unverified, verified, rejected }

// Extensions
extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.tenant:
        return 'Locataire';
      case UserRole.landlord:
        return 'Bailleur';
      case UserRole.agency:
        return 'Agence';
      case UserRole.seller:
        return 'Vendeur';
    }
  }

  String get name {
    switch (this) {
      case UserRole.tenant:
        return 'TENANT';
      case UserRole.landlord:
        return 'LANDLORD';
      case UserRole.agency:
        return 'AGENCY';
      case UserRole.seller:
        return 'SELLER';
    }
  }
}

extension ListingTypeExtension on ListingType {
  String get label => this == ListingType.rent ? 'Location' : 'Vente';
  String get name => this == ListingType.rent ? 'RENT' : 'SALE';
}

extension ListingStatusExtension on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.available:
        return 'Disponible';
      case ListingStatus.rented:
        return 'Loué';
      case ListingStatus.sold:
        return 'Vendu';
      case ListingStatus.pending:
        return 'En attente';
    }
  }
}
