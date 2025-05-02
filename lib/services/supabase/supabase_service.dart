import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Main Supabase service that provides access to specialized services
class SupabaseService {
  final SupabaseClient supabase;
  final _logger = Logger('SupabaseService');
  
  late PropertyService propertyService;
  late FavoritesService favoritesService;
  late UserService userService;
  late StorageService storageService;

  SupabaseService({required this.supabase}) {
    storageService = StorageService(supabase: supabase);
    propertyService = PropertyService(supabase: supabase, storageService: storageService);
    favoritesService = FavoritesService(supabase: supabase);
    userService = UserService(supabase: supabase);
  }


  

}
  
    
