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