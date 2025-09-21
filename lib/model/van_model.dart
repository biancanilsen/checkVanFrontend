class Van {
  final int id;
  final String nickname;
  final String plate;
  final int capacity;
  final int driverId;

  Van({
    required this.id,
    required this.nickname,
    required this.plate,
    required this.capacity,
    required this.driverId,
  });

  factory Van.fromJson(Map<String, dynamic> json) {
    return Van(
      id: json['id'] ?? 0,
      nickname: json['nickname'] ?? '',
      plate: json['plate'] ?? '',
      capacity: json['capacity'] ?? 0,
      driverId: json['driver_id'] ?? 0,
    );
  }
}

