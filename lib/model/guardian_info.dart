class GuardianInfo {
  final int id;
  final String name;
  final String? phone;

  GuardianInfo({
    required this.id,
    required this.name,
    this.phone,
  });

  factory GuardianInfo.fromJson(Map<String, dynamic> json) {
    return GuardianInfo(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }
}