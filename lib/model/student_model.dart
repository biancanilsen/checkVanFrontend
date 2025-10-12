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
  final School? school;
  final String shiftGoing;
  final String shiftReturn;
  final double latitude;
  final double longitude;
  final bool? isConfirmed;

  Student({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.guardianId,
    required this.address,
    required this.shiftGoing,
    required this.shiftReturn,
    this.schoolId,
    this.school,
    required this.latitude,
    required this.longitude,
    this.isConfirmed,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    bool isStudentConfirmed = true; // Padrão é true
    if (json['presences'] != null && (json['presences'] as List).isNotEmpty) {
      // Se a lista de presenças não for vazia, pega o status do primeiro registro
      final status = json['presences'][0]['status'];
      // O aluno está confirmado se o status for qualquer coisa diferente de 'NONE'
      isStudentConfirmed = (status != 'NONE');
    }

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
      school: json['school'] != null ? School.fromJson(json['school']) : null,
      shiftGoing: json['shift_going'] ?? 'Não informado',
      shiftReturn: json['shift_return'] ?? 'Não informado',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isConfirmed: isStudentConfirmed,
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
    'shift_going': shiftGoing,
    'shift_return': shiftReturn,
  };
}