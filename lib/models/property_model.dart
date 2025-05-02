//property_model.dart
class PropertyModel {
  final int id;
  final String userId;
  final String propertyName;
  final String address;
  final String? floor;
  final String city;
  final int bathrooms;
  final int bedrooms;
  final int squareFeet;
  final double price;
  final String description;
  final String type;
  final String listingType; // 'rent' or 'buy'
  final double rating;
  final DateTime createdAt;
  final bool isActive;
  final List<String> imageUrls;
  final String? primaryImageUrl;

  PropertyModel({
    required this.id,
    required this.userId,
    required this.propertyName,
    required this.address,
    this.floor,
    required this.city,
    required this.bathrooms,
    required this.bedrooms,
    required this.squareFeet,
    required this.price,
    required this.description,
    required this.type,
    required this.listingType,
    this.rating = 0.0,
    required this.createdAt,
    this.isActive = true,
    required this.imageUrls,
    this.primaryImageUrl,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      userId: json['user_id'],
      propertyName: json['property_name'],
      address: json['address'],
      floor: json['floor'],
      city: json['city'],
      bathrooms: json['bath_rooms'],
      bedrooms: json['bed_rooms'],
      squareFeet: json['square_feet'],
      price: json['price'].toDouble(),
      description: json['description'],
      type: json['type'],
      listingType: json['listing_type'],
      rating: json['rating']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      primaryImageUrl: json['primary_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'property_name': propertyName,
      'address': address,
      'floor': floor,
      'city': city,
      'bath_rooms': bathrooms,
      'bed_rooms': bedrooms,
      'square_feet': squareFeet,
      'price': price,
      'description': description,
      'type': type,
      'listing_type': listingType,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'image_urls': imageUrls,
      'primary_image_url': primaryImageUrl,
    };
  }
}
