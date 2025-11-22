class GuardianInfo {
  final int id;
  final String name;
  final String? phone;
  final String? phoneCountry;

  GuardianInfo({
    required this.id,
    required this.name,
    this.phone,
    this.phoneCountry,
  });

  factory GuardianInfo.fromJson(Map<String, dynamic> json) {
    return GuardianInfo(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      phoneCountry: json['phone_country'],
    );
  }
}