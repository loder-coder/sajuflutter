class SajuModel {
  final Map<String, dynamic> pillars;
  final Map<String, dynamic> elements;
  final int? recordId;

  SajuModel({
    required this.pillars,
    required this.elements,
    this.recordId,
  });

  factory SajuModel.fromJson(Map<String, dynamic> json) {
    return SajuModel(
      pillars: json['saju'] ?? {},
      elements: json['elements'] ?? {},
      recordId: json['record_id'],
    );
  }
}