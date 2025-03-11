class FlowerModel {
  final int id;
  final String commonName;
  final List<String> scientificName;
  final List<String> otherName;
  final String cycle;
  final String watering;
  final List<String> sunlight;
  final DefaultImage? defaultImage;

  FlowerModel({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.otherName,
    required this.cycle,
    required this.watering,
    required this.sunlight,
    this.defaultImage,
  });

  factory FlowerModel.fromJson(Map<String, dynamic> json) {
    return FlowerModel(
      id: json['id'] ?? 0,
      commonName: json['common_name'] ?? 'Unknown',
      scientificName:
          json['scientific_name'] != null
              ? List<String>.from(json['scientific_name'])
              : [],
      otherName:
          json['other_name'] != null
              ? List<String>.from(json['other_name'])
              : [],
      cycle: json['cycle'] ?? '',
      watering: json['watering'] ?? '',
      sunlight:
          json['sunlight'] != null ? List<String>.from(json['sunlight']) : [],
      defaultImage:
          json['default_image'] != null
              ? DefaultImage.fromJson(json['default_image'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'common_name': commonName,
      'scientific_name': scientificName,
      'other_name': otherName,
      'cycle': cycle,
      'watering': watering,
      'sunlight': sunlight,
      'default_image': defaultImage?.toJson(),
    };
  }
}

class DefaultImage {
  final int license;
  final String licenseName;
  final String licenseUrl;
  final String originalUrl;
  final String regularUrl;
  final String mediumUrl;
  final String smallUrl;
  final String thumbnail;

  DefaultImage({
    required this.license,
    required this.licenseName,
    required this.licenseUrl,
    required this.originalUrl,
    required this.regularUrl,
    required this.mediumUrl,
    required this.smallUrl,
    required this.thumbnail,
  });

  factory DefaultImage.fromJson(Map<String, dynamic> json) {
    return DefaultImage(
      license: json['license'] ?? 0,
      licenseName: json['license_name'] ?? '',
      licenseUrl: json['license_url'] ?? '',
      originalUrl: json['original_url'] ?? '',
      regularUrl: json['regular_url'] ?? '',
      mediumUrl: json['medium_url'] ?? '',
      smallUrl: json['small_url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license': license,
      'license_name': licenseName,
      'license_url': licenseUrl,
      'original_url': originalUrl,
      'regular_url': regularUrl,
      'medium_url': mediumUrl,
      'small_url': smallUrl,
      'thumbnail': thumbnail,
    };
  }
}
