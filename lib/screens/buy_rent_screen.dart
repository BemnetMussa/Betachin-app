// lib/screens/buy_rent_screen.dart

import 'package:flutter/material.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/app_drawer.dart';

class BuyRentScreen extends StatefulWidget {
  final int initialTabIndex;

  const BuyRentScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _BuyRentScreenState createState() => _BuyRentScreenState();
}

class _BuyRentScreenState extends State<BuyRentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Property> properties = [];
  List<Property> filteredProperties = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    // Load sample properties
    properties = Property.getSampleProperties();
    _filterProperties('');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterProperties(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProperties = properties;
      } else {
        filteredProperties =
            properties.where((property) {
              return property.title.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  property.location.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy & Rent Properties'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'BUY'), Tab(text: 'RENT')],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search Bar
          SearchBar(onSearch: _filterProperties),

          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // BUY Tab
                _buildPropertyList(false),
                // RENT Tab
                _buildPropertyList(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList(bool isForRent) {
    final List<Property> relevantProperties =
        filteredProperties
            .where((property) => property.isForRent == isForRent)
            .toList();

    if (relevantProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isForRent ? Icons.apartment : Icons.home,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isForRent ? 'rental' : 'sale'} properties found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: relevantProperties.length,
      itemBuilder: (context, index) {
        return PropertyCard(property: relevantProperties[index]);
      },
    );
  }
}
