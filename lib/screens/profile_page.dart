// Import required Flutter and Supabase packages
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ProfilePage widget, a stateful widget for displaying user profile and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// State class for ProfilePage, managing user data and UI state
class _ProfilePageState extends State<ProfilePage> {
  // Initialize Supabase client for authentication and database operations
  final _supabase = Supabase.instance.client;
  // State variables for user profile data
  String _email = '';
  String _userId = '';
  String _fullName = 'User';
  String? _phone;
  String? _address;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load user profile data on widget initialization
    _loadUserProfile();
  }

  // Fetch user profile data from Supabase auth and profiles table
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _email = user.email ?? 'No email found';
          _userId = user.id;
        });

        // Fetch additional profile details from profiles table
        try {
          final response = await _supabase
              .from('profiles')
              .select()
              .eq('id', _userId)
              .single();

          setState(() {
            _fullName = response['full_name'] ?? 'User';
            _phone = response['phone'];
            _address = response['address'];
          });
        } catch (e) {
          // Profile might not exist yet, which is fine
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }