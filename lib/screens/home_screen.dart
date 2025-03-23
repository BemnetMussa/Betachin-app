// File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_bar.dart';
import 'buy_rent_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Updated to use super parameter

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Property> _properties;
  late List<Property> _featuredProperties;
  String _searchQuery = '';
  bool _isLoading = false; // Suggestion: Added for loading state

  @override
  void initState() {
    super.initState();
    // In a real app, this would come from an API
    _properties = Property.getSampleProperties();
    // For featured properties, we're just using the first 3
    _featuredProperties = _properties.take(3).toList();
  }

  void _handleSearch(String query) {
    setState(() {
      _isLoading = true; // Suggestion: Show loading while filtering
      _searchQuery = query.toLowerCase();
      // Filter properties based on search query
      _properties =
          Property.getSampleProperties().where((property) {
            return property.title.toLowerCase().contains(_searchQuery) ||
                property.location.toLowerCase().contains(_searchQuery) ||
                property.description.toLowerCase().contains(_searchQuery) ||
                property.price.toString().contains(
                  _searchQuery,
                ); // Suggestion: Added price search
          }).toList();
      _featuredProperties = _properties.take(3).toList();
      _isLoading = false;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Properties'),
            content: const Text('Filtering options will be implemented later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BetaChin Real Estate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Logout functionality will be implemented later',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              PropertySearchBar(
                onSearch: _handleSearch,
                onFilterTap: _showFilterDialog,
              ),

              const SizedBox(height: 24),

              // Featured Listings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Listings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuyRentScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _isLoading // Suggestion: Show loading indicator
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    height: 320,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _featuredProperties.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 280,
                          child: PropertyCard(
                            property: _featuredProperties[index],
                          ),
                        );
                      },
                    ),
                  ),

              const SizedBox(height: 24),

              // Recent Properties
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Properties',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuyRentScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Grid of properties
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _properties.length > 4 ? 4 : _properties.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(property: _properties[index]);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
