import '../config/supabase_config.dart';
import '../../shared/models/user_model.dart';
import '../constants/enums.dart';

/// Service d'authentification
class AuthService {
  static final instance = AuthService._();

  AuthService._();

  // Enregistrer un nouvel utilisateur
  Future<User?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Erreur lors de l\'enregistrement');
      }

      // Créer le profil utilisateur
      final user = await _createUserProfile(
        userId: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        roles: [role],
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Se connecter
  Future<User?> login({required String email, required String password}) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Email ou mot de passe incorrect');
      }

      return await _getUserProfile(response.user!.id);
    } catch (e) {
      rethrow;
    }
  }

  // Se déconnecter
  Future<void> logout() async {
    try {
      await SupabaseConfig.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer l'utilisateur courant
  Future<User?> getCurrentUser() async {
    try {
      final user = SupabaseConfig.auth.currentUser;
      if (user == null) return null;

      return await _getUserProfile(user.id);
    } catch (e) {
      rethrow;
    }
  }

  // Profils privé
  Future<User> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
    required List<UserRole> roles,
  }) async {
    final now = DateTime.now();
    final rolesStr = roles.map((r) => r.name).toList();

    await SupabaseConfig.client.users.insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'roles': rolesStr,
      'verification_status': 'unverified',
      'rating': 0.0,
      'review_count': 0,
      'is_active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    return User(
      id: userId,
      email: email,
      fullName: fullName,
      phone: phone,
      roles: roles,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<User?> _getUserProfile(String userId) async {
    try {
      final response = await SupabaseConfig.client.users
          .select()
          .eq('id', userId)
          .single();

      return _mapToUser(response);
    } catch (e) {
      return null;
    }
  }

  User _mapToUser(Map<String, dynamic> data) {
    final roleStrings = List<String>.from(data['roles'] ?? []);
    final roles = roleStrings
        .map(
          (r) => UserRole.values.firstWhere(
            (role) => role.name == r,
            orElse: () => UserRole.tenant,
          ),
        )
        .toList();

    return User(
      id: data['id'],
      email: data['email'],
      fullName: data['full_name'],
      phone: data['phone'],
      profileImage: data['profile_image'],
      bio: data['bio'],
      roles: roles,
      verificationStatus: UserVerificationStatus.values.firstWhere(
        (s) => s.name == data['verification_status'],
        orElse: () => UserVerificationStatus.unverified,
      ),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['review_count'] ?? 0,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      isActive: data['is_active'] ?? true,
    );
  }
}
