import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'supabase_client.dart';

class AuthService {
  final SupabaseClient _supabaseClient;
  final _logger = Logger('AuthService');

  AuthService(this._supabaseClient);

  /// Refresh the authentication session to ensure the token is valid
  Future<void> refreshSession() async {
    // await _supabaseClient.refreshSession();
  }


}
