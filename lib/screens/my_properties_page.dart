// Import required packages for Flutter, Supabase, and custom utilities
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/reusable/property_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './property_detail.dart'; // Adjust import path as needed

// MyPropertiesPage widget, displays user-owned properties with management options
class MyPropertiesPage extends StatefulWidget {
  const MyPropertiesPage({super.key});

  @override
  State<MyPropertiesPage> createState() => _MyPropertiesPageState();
}

// State class for MyPropertiesPage, managing property data and UI state
class _MyPropertiesPageState extends State<MyPropertiesPage> {
  // Initialize Supabase service for data operations
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );

  // State variables for properties and loading status
  List<PropertyModel> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load user properties on widget initialization
    _loadProperties();
  }
  // Fetch user-owned properties from Supabase
  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _supabaseService.getUserProperties();
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading properties: ${e.toString()}')),
      );
    }
  }

  // Show options menu for editing, listing/delisting, or deleting a property
  void _showPropertyOptions(PropertyModel property) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Property'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/edit_property',
                    arguments: property,
                  ).then((_) => _loadProperties());
                },
              ),
              ListTile(
                leading: Icon(
                  property.isActive ? Icons.visibility_off : Icons.visibility,
                ),
                title: Text(
                  property.isActive ? 'Delist Property' : 'List Property',
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _togglePropertyListing(property);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Property',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteProperty(property);
                },
              ),
            ],
          ),
        );
      },
    );
  }
