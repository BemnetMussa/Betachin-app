// File: lib/screens/guidelines_screen.dart

import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key}); // Updated to use super parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guidelines'),
        // Suggestion: Removed duplicate logout button (already in drawer)
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BetaChin Real Estate Guidelines',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildGuideline(
              'For Buyers',
              'When looking to purchase property, it\'s important to understand the process and what you\'re committing to. Here are some tips to help you:',
              [
                'Get pre-approved for a mortgage before you start looking for a home.',
                'Consider working with a real estate agent who specializes in the areas you\'re interested in.',
                'Make a list of must-haves and nice-to-haves to help narrow down your search.',
                'Don\'t skip the home inspection, as it can reveal potential issues that may be costly to fix.',
                'Research the neighborhood, schools, and local amenities to ensure it fits your lifestyle.',
              ],
            ),

            const SizedBox(height: 24),

            _buildGuideline(
              'For Renters',
              'Renting a property comes with its own set of considerations. Here are some tips for potential renters:',
              [
                'Always read the lease agreement carefully before signing.',
                'Inspect the property thoroughly and document any existing damage before moving in.',
                'Understand the policies on security deposits, rent increases, and breaking the lease early.',
                'Check if utilities are included in the rent or if they will be separate expenses.',
                'Find out who is responsible for maintenance and repairs and how to report issues.',
              ],
            ),

            const SizedBox(height: 24),

            _buildGuideline(
              'For Property Owners',
              'If you\'re looking to list your property on BetaChin, please note the following guidelines:',
              [
                'Properties must be listed by the owner or authorized representative.',
                'All listings require accurate descriptions and clear photographs.',
                'Contact information must be kept up-to-date to ensure prompt communication.',
                'Pricing should be consistent with market rates for similar properties in the area.',
                'All legal documentation should be prepared before listing the property.',
                'Please contact the BetaChin administrator to have your property listed on the platform.',
              ],
            ),

            const SizedBox(height: 24),

            _buildGuideline(
              'Code of Conduct',
              'At BetaChin, we strive to create a respectful and transparent environment for all users:',
              [
                'Treat all parties with respect and professionalism.',
                'Provide honest and accurate information about properties.',
                'Respond to inquiries in a timely manner.',
                'Respect privacy and confidentiality of personal information.',
                'Report any suspicious or fraudulent activity to the platform administrators.',
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Note: These guidelines are subject to change. Please check back regularly for updates.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline(
    String title,
    String introduction,
    List<String> points,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(introduction, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        ...points.map(
          (point) => Padding(
            // Removed toList()
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(point, style: const TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
