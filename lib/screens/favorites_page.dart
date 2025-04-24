// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/reusable/property_card.dart';
import 'property_detail.dart';
import 'my_properties_page.dart';
import 'profile_page.dart'; // Import the new profile page

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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
