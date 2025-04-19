class SavedLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String displayName;
  final DateTime savedAt;

  SavedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.displayName,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'displayName': displayName,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    displayName: json['displayName'] as String,
    savedAt: json['savedAt'] != null 
      ? DateTime.parse(json['savedAt']) 
      : DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is SavedLocation &&
    runtimeType == other.runtimeType &&
    latitude == other.latitude &&
    longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
