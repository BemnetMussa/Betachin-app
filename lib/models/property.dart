// File: lib/models/property.dart

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final int bedrooms;
  final double bathrooms; // Changed from int to double
  final double area;
  final List<String> imageUrls;
  final bool isForRent;
  final String ownerName;
  final String ownerContact;
  final String ownerEmail;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrls,
    required this.isForRent,
    required this.ownerName,
    required this.ownerContact,
    required this.ownerEmail,
  });

  // This will be useful when implementing backend
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms:
          (json['bathrooms'] as num).toDouble(), // Updated to handle double
      area: (json['area'] as num).toDouble(),
      imageUrls:
          (json['imageUrls'] as List).map((url) => url as String).toList(),
      isForRent: json['isForRent'] as bool,
      ownerName: json['ownerName'] as String,
      ownerContact: json['ownerContact'] as String,
      ownerEmail: json['ownerEmail'] as String,
    );
  }

  // Suggestion: Added toString() for better debugging and display
  @override
  String toString() {
    return 'Property(id: $id, title: $title, price: $price, location: $location)';
  }

  // Sample data generator for testing
  static List<Property> getSampleProperties() {
    return [
      Property(
        id: '1',
        title: 'Modern Apartment in Downtown',
        description:
            'A beautiful modern apartment located in the heart of downtown. Features an open concept living space, updated kitchen, and stunning city views.',
        price: 1800,
        location: 'Downtown, City Center',
        bedrooms: 2,
        bathrooms: 2,
        area: 1200,
        imageUrls: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        ],
        isForRent: true,
        ownerName: 'John Smith',
        ownerContact: '(123) 456-7890',
        ownerEmail: 'john.smith@example.com',
      ),
      Property(
        id: '2',
        title: 'Spacious Family Home',
        description:
            'Perfect for families, this spacious home features a large backyard, updated kitchen, and is located in a quiet neighborhood close to schools and parks.',
        price: 350000,
        location: 'Suburbia, Green Hills',
        bedrooms: 4,
        bathrooms: 3,
        area: 2500,
        imageUrls: [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
        ],
        isForRent: false,
        ownerName: 'Emily Johnson',
        ownerContact: '(234) 567-8901',
        ownerEmail: 'emily.johnson@example.com',
      ),
      Property(
        id: '3',
        title: 'Luxury Penthouse with Pool',
        description:
            'Stunning penthouse featuring high-end finishes, floor-to-ceiling windows, private rooftop pool, and panoramic ocean views.',
        price: 5000,
        location: 'Ocean Drive, Beachfront',
        bedrooms: 3,
        bathrooms: 3.5,
        area: 3000,
        imageUrls: [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
        ],
        isForRent: true,
        ownerName: 'Robert Chen',
        ownerContact: '(345) 678-9012',
        ownerEmail: 'robert.chen@example.com',
      ),
      Property(
        id: '4',
        title: 'Charming Cottage Near Lake',
        description:
            'Adorable cottage with lots of character, featuring a cozy fireplace, updated bathroom, and is just steps away from the lake.',
        price: 275000,
        location: 'Lakeside, Blue Water',
        bedrooms: 2,
        bathrooms: 1,
        area: 1000,
        imageUrls: [
          'https://images.unsplash.com/photo-1510798831971-661eb04b3739',
        ],
        isForRent: false,
        ownerName: 'Sophia Williams',
        ownerContact: '(456) 789-0123',
        ownerEmail: 'sophia.williams@example.com',
      ),
      Property(
        id: '5',
        title: 'Modern Condo in City Center',
        description:
            'Modern condo with sleek design, featuring hardwood floors, gourmet kitchen, and is walking distance to restaurants and shops.',
        price: 2200,
        location: 'City Center, Uptown',
        bedrooms: 1,
        bathrooms: 1,
        area: 850,
        imageUrls: [
          'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
        ],
        isForRent: true,
        ownerName: 'David Brown',
        ownerContact: '(567) 890-1234',
        ownerEmail: 'david.brown@example.com',
      ),
    ];
  }
}
