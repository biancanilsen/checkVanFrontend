class School {
  final int id;
  final String name;
  final String address;

  School({required this.id, required this.name, required this.address});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nome indisponível',
      address: json['addres'] ?? 'Endereço indisponível'
    );
  }
}