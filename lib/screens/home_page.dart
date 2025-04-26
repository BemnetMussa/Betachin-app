import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/reusable/property_card.dart';
import 'property_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );

  List<PropertyModel> _properties = [];
  List<int> _favoriteIds = [];
  bool _isLoading = true;
  bool _showRentOnly = false;
  bool _showBuyOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _supabaseService.getProperties(
        rentOnly: _showRentOnly,
        buyOnly: _showBuyOnly,
        searchQuery: _searchQuery,
      );
      final favorites = await _supabaseService.getUserFavorites();

      if (mounted) {
        setState(() {
          _properties = properties;
          _favoriteIds = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading properties: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(int propertyId) async {
    try {
      await _supabaseService.toggleFavorite(propertyId);
      if (mounted) {
        setState(() {
          if (_favoriteIds.contains(propertyId)) {
            _favoriteIds.remove(propertyId);
          } else {
            _favoriteIds.add(propertyId);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: !_showRentOnly && !_showBuyOnly,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _showRentOnly = false;
                              _showBuyOnly = false;
                            });
                            _loadData();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('For Rent'),
                        selected: _showRentOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showRentOnly = selected;
                            if (selected) _showBuyOnly = false;
                          });
                          _loadData();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('For Sale'),
                        selected: _showBuyOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showBuyOnly = selected;
                            if (selected) _showRentOnly = false;
                          });
                          _loadData();
                        },
                      ),
                    ],
                  ),
                ),

                // Properties list
                Expanded(
                  child: _properties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.home_work,
                                size: 64,
                                color: Color.fromARGB(255, 255, 54, 54),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No properties found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: const Color.fromARGB(255, 255, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _properties.length,
                            itemBuilder: (context, index) {
                              final property = _properties[index];
                              final isFavorite =
                                  _favoriteIds.contains(property.id);
                              print("Image URL: ${property.primaryImageUrl}");
                              return PropertyCard(
                                id: property.id,
                                propertyName: property.propertyName,
                                address: "${property.address}, ${property.city}",
                                rating: property.rating,
                                price: property.price,
                                isRent: property.listingType == 'rent',
                                imageUrl: property.primaryImageUrl ?? '',
                                bedrooms: property.bedrooms,
                                bathrooms: property.bathrooms,
                                squareFeet: property.squareFeet,
                                isFavorite: isFavorite,
                                onFavoritePressed: () =>
                                    _toggleFavorite(property.id),
                                onCardPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailPage(
                                        propertyId: property.id,
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_property').then((_) => _loadData());
        },
        tooltip: 'Add Property',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            // Already on home page
          } else if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Properties'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter location, name, etc.',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = controller.text;
                });
                _loadData();
                Navigator.pop(context);
              },
              child: const Text('SEARCH'),
            ),
          ],
        );
      },
    );
  }
}