class Product {
  final String id, name, desc, image, buyUrl;
  final int points;
  Product({required this.id, required this.name, required this.desc, required this.points, required this.image, required this.buyUrl});
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'], name: json['name'], desc: json['desc'], points: json['points'], image: json['image'], buyUrl: json['buyUrl'],
  );
} 