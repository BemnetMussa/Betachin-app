import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class to handle Supabase authentication operations
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Signs up a new user with email and password
  /// Returns null on success, or an error message on failure
  Future<String?> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        // Sign up successful
        return null;
      } else {
        // Sign up failed, but no specific error
        return 'Sign up failed. Please try again.';
      }
    } on AuthException catch (e) {
      // Handle specific authentication errors
      if (e.message.contains('email')) {
        return 'This email is already registered.';
      } else if (e.message.contains('password')) {
        return 'Password is too weak. Please use a stronger password.';
      }
      return e.message;
    } catch (e) {
      // Handle unexpected errors
      return 'An unexpected error occurred: $e';
    }
  }

  /// Logs in a user with email and password
  /// Returns null on success, or an error message on failure
  Future<String?> logIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        // Login successful
        return null;
      } else {
        // Login failed, but no specific error
        return 'Login failed. Please check your credentials.';
      }
    } on AuthException catch (e) {
      // Handle specific authentication errors
      if (e.message.contains('invalid')) {
        return 'Invalid email or password.';
      }
      return e.message;
    } catch (e) {
      // Handle unexpected errors
      return 'An unexpected error occurred: $e';
    }
  }

  /// Logs out the current user
  /// Returns null on success, or an error message on failure
  Future<String?> logOut() async {
    try {
      await _client.auth.signOut();
      return null;
    } catch (e) {
      return 'Error logging out: $e';
    }
  }

  /// Gets the current user's email
  String? getCurrentUserEmail() {
    final user = _client.auth.currentUser;
    return user?.email;
  }
}
