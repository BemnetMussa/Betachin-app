// File: lib/screens/property_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/property.dart';
import '../widgets/app_drawer.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  }); // Updated to use super parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        // Suggestion: Removed duplicate logout button (already in drawer)
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[300],
                child:
                    property.imageUrls.isNotEmpty
                        ? Image.network(
                          property.imageUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.home, size: 80),
                            );
                          },
                        )
                        : const Center(child: Icon(Icons.home, size: 80)),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              property.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Price
            Text(
              '\$${property.price.toStringAsFixed(0)}${property.isForRent ? '/month' : ''}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 4),
                Text(
                  property.location,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Features
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeature(Icons.king_bed, '${property.bedrooms} Bedrooms'),
                _buildFeature(Icons.bathtub, '${property.bathrooms} Bathrooms'),
                _buildFeature(Icons.square_foot, '${property.area} sq ft'),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(property.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 24),

            // Owner Information
            const Text(
              'Owner Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildOwnerInfo('Name', property.ownerName),
            _buildOwnerInfo('Contact', property.ownerContact),
            _buildOwnerInfo('Email', property.ownerEmail),

            const SizedBox(height: 24),

            // Contact Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Contact ${property.ownerName} at ${property.ownerContact}',
                      ),
                    ),
                  );
                },
                child: const Text('Contact Owner'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildOwnerInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
