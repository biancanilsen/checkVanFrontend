class Student {
  final String name;
  final DateTime birthDate;

  Student({required this.name, required this.birthDate});

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthDate': birthDate.toIso8601String(),
  };

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
    );
  }
}
