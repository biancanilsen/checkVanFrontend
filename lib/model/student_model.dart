class Student {
  final int id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final int guardianId;

  Student({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.guardianId,
  });

  /// 3. MÉTODO `fromJson`
  /// Converte um mapa (JSON) em um objeto Student.
  /// Lida com valores nulos para evitar que o aplicativo quebre.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nome Indisponível',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : DateTime(1900, 1, 1), // Usa uma data muito antiga como padrão

      gender: json['gender'] ?? 'não informado',

      guardianId: json['guardian_id'] ?? 0,
    );
  }

  /// 4. MÉTODO `toJson`
  /// Converte um objeto Student em um mapa (JSON) para envio ao backend.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birth_date': birthDate.toIso8601String(),
    'gender': gender,
    'guardian_id': guardianId,
  };
}