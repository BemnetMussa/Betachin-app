// lib/screens/my_properties_page.dart
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';
import '../utils/reusable/property_card.dart'; // Fixed path to match directory structure
import 'package:supabase_flutter/supabase_flutter.dart'; // Added Supabase import

class MyPropertiesPage extends StatefulWidget {
  const MyPropertiesPage({super.key}); // Using super parameter

  @override
  State<MyPropertiesPage> createState() => _MyPropertiesPageState();
}

class _MyPropertiesPageState extends State<MyPropertiesPage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );
  
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProperties();
  }
  
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
                title: const Text('Delete Property', style: TextStyle(color: Colors.red)),
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
  
  Future<void> _togglePropertyListing(PropertyModel property) async {
    try {
      await _supabaseService.togglePropertyListing(property.id, !property.isActive);
      
      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            property.isActive 
                ? 'Property delisted successfully' 
                : 'Property listed successfully',
          ),
        ),
      );
      
      _loadProperties();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  void _confirmDeleteProperty(PropertyModel property) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Property'),
          content: Text(
            'Are you sure you want to delete "${property.propertyName}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
