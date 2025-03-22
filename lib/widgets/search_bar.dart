// File: lib/widgets/search_bar.dart

import 'package:flutter/material.dart';

class PropertySearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function()? onFilterTap;

  const PropertySearchBar({
    super.key, // Updated to use super parameter
    required this.onSearch,
    this.onFilterTap,
  });

  @override
  State<PropertySearchBar> createState() => _PropertySearchBarState();
}

class _PropertySearchBarState extends State<PropertySearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(
              alpha: 0.2,
            ), // Updated to use withValues
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by location, price, etc.',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onSubmitted: (value) {
                widget.onSearch(value);
              },
            ),
          ),
          // Suggestion: Added clear button
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                widget.onSearch('');
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: widget.onFilterTap,
          ),
        ],
      ),
    );
  }
}
