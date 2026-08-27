import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles login/logout for the shared "Manage Data" admin account.
/// This is separate from the app's normal student sign-up/login system.
class SupabaseAuthService {
  SupabaseAuthService._();
  static final SupabaseAuthService instance = SupabaseAuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// True if someone is currently logged in as the shared admin account.
  bool get isLoggedIn => _client.auth.currentSession != null;

  /// Attempts to log in with the shared admin email/password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> logIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> logOut() async {
    await _client.auth.signOut();
  }
}