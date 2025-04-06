import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Handle logout
  Future<void> _handleLogout() async {
    final authService = AuthService();
    final error = await authService.logOut();

    if (!mounted) return; // Guard against using context if widget is unmounted

    if (error != null) {
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      // Logout successful, navigation to WelcomeScreen is handled by AuthWrapper
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userEmail = authService.getCurrentUserEmail() ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('BetaChin'),
        actions: [
          // Log Out button in the app bar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: _handleLogout, // Removed context parameter
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Text(
                'Welcome, $userEmail!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Placeholder for future content
              const Text(
                'Property listings coming soon!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
