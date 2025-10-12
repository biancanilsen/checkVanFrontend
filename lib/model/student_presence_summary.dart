class StudentPresenceSummary {
  final int id;
  final String name;
  final String? imageProfile;
  final bool isPresenceConfirmed;

  StudentPresenceSummary({
    required this.id,
    required this.name,
    this.imageProfile,
    required this.isPresenceConfirmed,
  });

  factory StudentPresenceSummary.fromJson(Map<String, dynamic> json) {
    return StudentPresenceSummary(
      id: json['id'],
      name: json['name'],
      imageProfile: json['image_profile'],
      isPresenceConfirmed: json['is_presence_confirmed'],
    );
  }
}