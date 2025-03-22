// File: lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/buy_rent_screen.dart';
import '../screens/guidelines_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key}); // Updated to use super parameter

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Suggestion: Added user profile section
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guest User', // Placeholder for user name
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find your dream home',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Buy & Rent'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BuyRentScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Guidelines'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GuidelinesScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Logout functionality will be implemented later',
                  ),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
