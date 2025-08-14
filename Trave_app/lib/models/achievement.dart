class Achievement {
  final String id;
  final String name;
  final String desc;
  final String icon;
  final bool unlocked;

  Achievement({required this.id, required this.name, required this.desc, required this.icon, this.unlocked = false});

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    name: json['name'],
    desc: json['desc'],
    icon: json['icon'],
    unlocked: json['unlocked'] ?? false,
  );
} 