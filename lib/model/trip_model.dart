class Trip {
  final int teamId;
  final String tipo;
  final String rota;
  final String escola;
  final int quantidadeAlunos;
  final String horarioInicio;
  final String comecaEm;

  Trip({
    required this.teamId,
    required this.tipo,
    required this.rota,
    required this.escola,
    required this.quantidadeAlunos,
    required this.horarioInicio,
    required this.comecaEm,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      teamId: json['teamId'] as int,
      tipo: json['tipo'] as String,
      rota: json['rota'] as String,
      escola: json['escola'] as String,
      quantidadeAlunos: json['quantidade_alunos'] as int,
      horarioInicio: json['horario_inicio'] as String,
      comecaEm: json['comeca_em'] as String,
    );
  }
}