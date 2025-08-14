class Binding {
  final int id;
  final String touristId;
  final String guideId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Binding({
    required this.id,
    required this.touristId,
    required this.guideId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Binding.fromJson(Map<String, dynamic> json) {
    return Binding(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      touristId: json['tourist_id'].toString(),
      guideId: json['guide_id'].toString(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 