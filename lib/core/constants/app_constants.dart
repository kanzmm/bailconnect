// App Constants
class AppConstants {
  // App Info
  static const String appName = 'BailConnect';
  static const String appVersion = '1.0.0';
  static const String appSlogan = 'Louez, signez, payez — en toute confiance.';

  // Supabase
  static const String supabaseUrl = 'https://vzblfxssaisnpfavhjif.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_meuibhtV1LZ0AlMPOF57NA_WBLpqnDO';

  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_KEY';

  // Firebase
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT';

  // Cities
  static const List<String> cities = [
    'Lubumbashi',
    'Kinshasa',
    'Goma',
    'Bukavu',
    'Kananga',
  ];

  // Amenities
  static const List<String> amenities = [
    'Eau chaude',
    'Climatisation',
    'Jardin',
    'Garage',
    'Ascenseur',
    'Balcon',
    'Internet',
    'Cuisine équipée',
    'Terrasse',
    'Piscine',
    'Sécurité 24h',
  ];

  // Mobile Money Providers
  static const List<String> mobileMoneyProviders = [
    'Orange Money',
    'Airtel Money',
    'M-Pesa',
    'Vodafone Cash',
  ];

  // Tabs Navigation
  static const List<String> mainBottomNavItems = [
    'Accueil',
    'Recherche',
    'Publier',
    'Messages',
    'Profil',
  ];
}

// API Endpoints
class ApiEndpoints {
  static const String baseUrl = 'YOUR_API_BASE_URL';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String verifyEmail = '/auth/verify-email';

  // Listings
  static const String listings = '/listings';
  static const String createListing = '/listings/create';
  static const String updateListing = '/listings/update';
  static const String deleteListing = '/listings/delete';
  static const String searchListings = '/listings/search';

  // Users
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile/update';
  static const String verifyUser = '/users/verify';
}

// Sizes & Spacing
class Sizes {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double borderRadius = 12;
  static const double borderRadiusLarge = 20;
}

// Animation Duration
class AnimationDuration {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
}
