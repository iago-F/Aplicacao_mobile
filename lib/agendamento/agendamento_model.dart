class VisitaModel {
  final String id; // ID da visita
  final String casaId; // ID da casa
  final String userId; // ID do usuário logado
  final String nomeCompleto; // Nome completo do usuário
  final String telefone; // Telefone do usuário
  final DateTime dataHora; // Data e horário da visita

  VisitaModel({
    required this.id,
    required this.casaId,
    required this.userId,
    required this.nomeCompleto,
    required this.telefone,
    required this.dataHora,
  });

  // Converte para JSON para salvar no banco de dados
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'casaId': casaId,
      'userId': userId,
      'nomeCompleto': nomeCompleto,
      'telefone': telefone,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  // Constrói a partir de JSON
  factory VisitaModel.fromJson(Map<String, dynamic> json) {
    return VisitaModel(
      id: json['id'],
      casaId: json['casaId'],
      userId: json['userId'],
      nomeCompleto: json['nomeCompleto'],
      telefone: json['telefone'],
      dataHora: DateTime.parse(json['dataHora']),
    );
  }
}
