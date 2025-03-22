// File: lib/screens/buy_rent_screen.dart

import 'package:flutter/material.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_bar.dart';

class BuyRentScreen extends StatefulWidget {
  const BuyRentScreen({super.key}); // Updated to use super parameter

  @override
  State<BuyRentScreen> createState() => _BuyRentScreenState();
}

class _BuyRentScreenState extends State<BuyRentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Property> _allProperties;
  late List<Property> _buyProperties;
  late List<Property> _rentProperties;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // In a real app, this would come from an API
    _allProperties = Property.getSampleProperties();
    _buyProperties = _allProperties.where((p) => !p.isForRent).toList();
    _rentProperties = _allProperties.where((p) => p.isForRent).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
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

  List<Property> _getFilteredProperties(List<Property> properties) {
    if (_searchQuery.isEmpty) return properties;

    return properties.where((property) {
      return property.title.toLowerCase().contains(_searchQuery) ||
          property.location.toLowerCase().contains(_searchQuery) ||
          property.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAll = _getFilteredProperties(_allProperties);
    final filteredBuy = _getFilteredProperties(_buyProperties);
    final filteredRent = _getFilteredProperties(_rentProperties);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        // Suggestion: Removed duplicate logout button (already in drawer)
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'All'), Tab(text: 'Buy'), Tab(text: 'Rent')],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PropertySearchBar(
              onSearch: _handleSearch,
              onFilterTap: _showFilterDialog,
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Properties Tab
                _buildPropertyList(filteredAll),

                // Buy Properties Tab
                _buildPropertyList(filteredBuy),

                // Rent Properties Tab
                _buildPropertyList(filteredRent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList(List<Property> properties) {
    if (properties.isEmpty) {
      return const Center(child: Text('No properties found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return PropertyCard(property: properties[index]);
      },
    );
  }
}
