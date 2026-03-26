import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Service de configuration Supabase
class SupabaseConfig {
  static late Supabase _auth;
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    _auth = await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = _auth.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    return _client!;
  }

  static GoTrueClient get auth => client.auth;
}

/// Extension pour simplifier l'accès
extension SupabaseExtension on SupabaseClient {
  // Exemples de références aux tables
  SupabaseQueryBuilder get users => from('users');

  SupabaseQueryBuilder get listings => from('listings');

  SupabaseQueryBuilder get messages => from('messages');

  SupabaseQueryBuilder get conversations => from('conversations');

  SupabaseQueryBuilder get transactions => from('transactions');

  SupabaseQueryBuilder get favorites => from('favorites');
}
