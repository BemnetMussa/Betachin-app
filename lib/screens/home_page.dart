// Import required packages for Flutter, Supabase, and custom utilities
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/reusable/property_card.dart';
import 'property_detail.dart';
import 'package:logging/logging.dart';
import './my_properties_page.dart'; // Import MyPropertiesPage
import './favorites_page.dart'; // Import FavoritesPage
import './profile_page.dart'; // Import ProfilePage

// HomePage widget, the main interface for property listings with navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage, managing property data and UI state
class _HomePageState extends State<HomePage> {
  // Initialize Supabase service for data operations
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );
  // Logger for debugging and error tracking
  final _logger = Logger('HomePage');

  // State variables for properties, favorites, and UI
  List<PropertyModel> _properties = [];
  List<int> _favoriteIds = [];
  bool _isLoading = true;
  bool _showRentOnly = false;
  bool _showBuyOnly = false;
  String _searchQuery = '';
  int _currentIndex = 0; // Track current navigation index

  @override
  void initState() {
    super.initState();
    // Load properties and favorites on widget initialization
    _loadData();
  }

  // Fetch properties and user favorites from Supabase
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

  // Toggle favorite status for a property
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

  // Build the main UI with navigation and conditional FAB
  @override
  Widget build(BuildContext context) {
    // Define pages for navigation
    final List<Widget> _pages = [
      _buildHomePage(),
      const FavoritesPage(),
      const MyPropertiesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      // AppBar: Topmost component displaying the app title
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Betachin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      // Body: Displays the selected page based on navigation index
      body: _pages[_currentIndex],
      // FloatingActionButton: Shown only on My Properties page to add a new property
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_property')
                    .then((_) => _loadData());
              },
              tooltip: 'Add Property',
              child: const Icon(Icons.add),
            )
          : null,
      // BottomNavigationBar: Navigation footer for switching pages
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Important for 4+ items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.apartment), label: 'My Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Build the home page content with property listings
  Widget _buildHomePage() {
    return Column(
      children: [
        // Title Section: Encourages users to explore properties
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Explore your home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        // Filter and Search Card: Horizontal row of filter chips and search button
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
              const SizedBox(width: 8),
              // Search button to open search dialog
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _showSearchDialog();
                  },
                ),
              ),
            ],
          ),
        ),

        // Properties List Card: Scrollable list of property cards
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _properties.isEmpty
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
                          final isFavorite = _favoriteIds.contains(property.id);

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
    );
  }

  // Show dialog for searching properties
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
