class FlowerModel {
  final String id;
  final String commonName;
  final List<String> scientificName;
  final String picture;
  final String humidity;
  final String lighting;
  final String wateringCycle;

  FlowerModel({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.picture,
    required this.humidity,
    required this.lighting,
    required this.wateringCycle,
  });

  factory FlowerModel.fromJson(Map<String, dynamic> json) {
    return FlowerModel(
      id: json['id'].toString(),
      commonName: json['common_name'] ?? 'Unknown',
      scientificName: _ensureList(json['scientific_name']),
      picture: json['picture'] ?? 'https://via.placeholder.com/150?text=No+Image',
      humidity: json['Humidity'] ?? 'Unknown',
      lighting: json['Lighting'] ?? 'Unknown',
      wateringCycle: json['Watering Cycle'] ?? 'Unknown',
    );
  }

  get defaultImage => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'common_name': commonName,
      'scientific_name': scientificName,
      'picture': picture,
      'Humidity': humidity,
      'Lighting': lighting,
      'Watering Cycle': wateringCycle,
    };
  }

  static List<String> _ensureList(dynamic value) {
    if (value is String) {
      return [value];
    } else if (value is List) {
      return List<String>.from(value);
    }
    return [];
  }
}