class SurveyStats {
  final int total;
  final Map<String, int> interest;
  final Map<String, int> diets;
  final Map<String, int> expect;
  final Map<String, int> gender;
  final Map<String, int> ageGroup;
  final Map<String, int> monthlyIncome;
  final Map<String, int> culturalIdentity;
  final Map<String, int> psychologicalTraits;
  final Map<String, int> travelFrequency;

  SurveyStats({
    required this.total,
    required this.interest,
    required this.diets,
    required this.expect,
    required this.gender,
    required this.ageGroup,
    required this.monthlyIncome,
    required this.culturalIdentity,
    required this.psychologicalTraits,
    required this.travelFrequency,
  });

  factory SurveyStats.fromJson(Map<String, dynamic> json) {
    return SurveyStats(
      total: json['total'] ?? 0,
      interest: Map<String, int>.from(json['interest'] ?? {}),
      diets: Map<String, int>.from(json['diets'] ?? {}),
      expect: Map<String, int>.from(json['expect'] ?? {}),
      gender: Map<String, int>.from(json['gender'] ?? {}),
      ageGroup: Map<String, int>.from(json['ageGroup'] ?? {}),
      monthlyIncome: Map<String, int>.from(json['monthlyIncome'] ?? {}),
      culturalIdentity: Map<String, int>.from(json['culturalIdentity'] ?? {}),
      psychologicalTraits: Map<String, int>.from(json['psychologicalTraits'] ?? {}),
      travelFrequency: Map<String, int>.from(json['travelFrequency'] ?? {}),
    );
  }
}