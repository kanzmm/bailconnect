import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../core/constants/enums.dart';
import '../config/supabase_config.dart';
import 'auth_service.dart';

/// Notifier pour l'état d'authentification
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService = AuthService.instance;

  AuthNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRole(UserRole role) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    // Vérifier si l'utilisateur a déjà ce rôle
    if (currentUser.roles.contains(role)) return;

    try {
      // Ajouter le rôle à la liste existante
      final updatedRoles = [...currentUser.roles, role];
      final rolesStr = updatedRoles.map((r) => r.name).toList();

      // Mettre à jour dans Supabase
      await SupabaseConfig.client.users
          .update({
            'roles': rolesStr,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser.id);

      // Mettre à jour l'état local
      final updatedUser = currentUser.copyWith(
        roles: updatedRoles,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider pour l'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  return AuthNotifier();
});

/// Provider sélecteur pour l'état d'authentification
final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.value != null;
});

/// Provider sélecteur pour l'utilisateur courant
final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.value;
});

/// Provider sélecteur pour le rôle primaire
final currentRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.roles.isNotEmpty ?? false ? user!.roles.first : null;
});

/// Provider sélecteur pour vérifier un rôle spécifique
final hasRoleProvider = Provider.family<bool, UserRole>((ref, role) {
  final user = ref.watch(currentUserProvider);
  return user?.hasRole(role) ?? false;
});

/// Provider pour le chargement
final isLoadingProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.isLoading;
});

/// Provider pour les erreurs
final authErrorProvider = Provider<String?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.maybeWhen(
    error: (error, _) => error.toString(),
    orElse: () => null,
  );
});
