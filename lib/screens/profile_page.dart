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
   // Show dialog for changing user password
  void _showChangePasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _updatePassword(passwordController.text);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
// Update user password via Supabase auth
  Future<void> _updatePassword(String newPassword) async {
    try {
      setState(() => _isLoading = true);
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
 // Show dialog for editing user profile details
  Future<void> _editProfile() async {
    final TextEditingController nameController =
        TextEditingController(text: _fullName);
    final TextEditingController phoneController =
        TextEditingController(text: _phone);
    final TextEditingController addressController =
        TextEditingController(text: _address);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);

        await _supabase.from('profiles').upsert({
          'id': _userId,
          'full_name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'updated_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          _fullName = nameController.text;
          _phone = phoneController.text;
          _address = addressController.text;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update profile: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }