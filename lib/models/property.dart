// lib/models/property.dart

class Property {
  final String id;
  final String title;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final List<String> imageUrls;
  final String description;
  final String ownerName;
  final String ownerContact;
  final String ownerEmail;
  final bool isForRent; // true if for rent, false if for sale

  Property({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrls,
    required this.description,
    required this.ownerName,
    required this.ownerContact,
    required this.ownerEmail,
    required this.isForRent,
  });

  // Sample data for testing UI
  static List<Property> getSampleProperties() {
    return [
      Property(
        id: '1',
        title: 'Modern Apartment in Downtown',
        price: 2500,
        location: 'Downtown, City',
        bedrooms: 2,
        bathrooms: 1,
        area: 850,
        imageUrls: ['https://via.placeholder.com/300x200'],
        description: 'Beautiful apartment with city view and modern amenities.',
        ownerName: 'John Doe',
        ownerContact: '+1234567890',
        ownerEmail: 'john@example.com',
        isForRent: true,
      ),
      Property(
        id: '2',
        title: 'Family House with Garden',
        price: 450000,
        location: 'Suburban Area, City',
        bedrooms: 4,
        bathrooms: 3,
        area: 2200,
        imageUrls: ['https://via.placeholder.com/300x200'],
        description: 'Spacious family house with large garden and garage.',
        ownerName: 'Jane Smith',
        ownerContact: '+1987654321',
        ownerEmail: 'jane@example.com',
        isForRent: false,
      ),
      Property(
        id: '3',
        title: 'Studio Apartment near University',
        price: 1200,
        location: 'University District, City',
        bedrooms: 0,
        bathrooms: 1,
        area: 500,
        imageUrls: ['https://via.placeholder.com/300x200'],
        description: 'Cozy studio apartment perfect for students.',
        ownerName: 'Mike Johnson',
        ownerContact: '+1122334455',
        ownerEmail: 'mike@example.com',
        isForRent: true,
      ),
      Property(
        id: '4',
        title: 'Luxury Villa with Pool',
        price: 950000,
        location: 'Beachside, City',
        bedrooms: 5,
        bathrooms: 4,
        area: 3500,
        imageUrls: ['https://via.placeholder.com/300x200'],
        description: 'Luxury villa with swimming pool and ocean view.',
        ownerName: 'Sarah Williams',
        ownerContact: '+1567890123',
        ownerEmail: 'sarah@example.com',
        isForRent: false,
      ),
    ];
  }
}
