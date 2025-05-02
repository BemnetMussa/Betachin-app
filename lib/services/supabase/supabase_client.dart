import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A singleton class that provides access to the Supabase client.
class SupabaseClient {
  final SupabaseClient _client;
  final _logger = Logger('SupabaseClient');

  SupabaseClient(this._client);

  SupabaseClient get client => _client;

}
