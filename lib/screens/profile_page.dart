// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  String _email = '';
  String _userId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _email = user.email ?? 'No email found';
          _userId = user.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 70, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'User ID: $_userId',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: $_email',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    // For now, just show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Edit profile not implemented yet')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Change Password'),
                  onTap: () {
                    // For now, just show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Change password not implemented yet')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log Out'),
                  onTap: () {
                    _handleLogout();
                  },
                ),
              ],
            ),
          );
  }

  // Fixed method to properly handle async operations with BuildContext
  void _handleLogout() async {
    // Store the context before the async operation
    final navigatorContext = context;

    try {
      await _supabase.auth.signOut();

      // After signOut completes, check if widget is still mounted
      if (!mounted) return;

      // Now it's safe to use the stored context after checking mounted
      Navigator.pushReplacementNamed(navigatorContext, '/login');
    } catch (e) {
      if (!mounted) return;

      // Now it's safe to use the stored context after checking mounted
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }
}
