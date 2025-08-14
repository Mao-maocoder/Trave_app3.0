class TouristSpot {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String descriptionEn;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final String addressEn;
  final List<String> tags;
  final List<String> tagsEn;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final String category;

  TouristSpot({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.addressEn,
    required this.tags,
    required this.tagsEn,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFavorite = false,
    required this.category,
  });

  factory TouristSpot.fromJson(Map<String, dynamic> json) {
    return TouristSpot(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      description: json['description'],
      descriptionEn: json['descriptionEn'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      addressEn: json['addressEn'],
      tags: List<String>.from(json['tags']),
      tagsEn: List<String>.from(json['tagsEn']),
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'addressEn': addressEn,
      'tags': tags,
      'tagsEn': tagsEn,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFavorite': isFavorite,
      'category': category,
    };
  }

  TouristSpot copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? address,
    String? addressEn,
    List<String>? tags,
    List<String>? tagsEn,
    double? rating,
    int? reviewCount,
    bool? isFavorite,
    String? category,
  }) {
    return TouristSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      addressEn: addressEn ?? this.addressEn,
      tags: tags ?? this.tags,
      tagsEn: tagsEn ?? this.tagsEn,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }
} 