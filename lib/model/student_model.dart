class School {
  final int id;
  final String name;

  School({required this.id, required this.name});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nome da escola indisponível',
    );
  }
}

class Student {
  final int id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final int guardianId;
  final String address;
  final int? schoolId;
  final School? school; // Objeto da escola aninhado

  Student({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.guardianId,
    required this.address,
    this.schoolId,
    this.school,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nome Indisponível',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : DateTime(1900, 1, 1),
      gender: json['gender'] ?? 'não informado',
      guardianId: json['guardian_id'] ?? 0,
      address: json['address'] ?? 'Endereço não informado',
      schoolId: json['school_id'],
      // Verifica se o objeto 'school' existe no JSON antes de criá-lo
      school: json['school'] != null ? School.fromJson(json['school']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birth_date': birthDate.toIso8601String(),
    'gender': gender,
    'guardian_id': guardianId,
    'address': address,
    'school_id': schoolId,
  };
}