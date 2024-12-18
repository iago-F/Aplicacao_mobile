import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? id;
  String? nome;
  String? email;
  String? senha;
  String? image;
  String? cpf;
  DateTime? data_nascimento;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    this.senha,
    this.image,
    this.cpf,
    this.data_nascimento,
  });

  // Método para converter o objeto para JSON, adequado para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'image': image,
      'cpf': cpf,
      'data_nascimento': data_nascimento?.toIso8601String(),
    };
  }

  // Construtor que cria um objeto Usuario a partir de um Map
  Usuario.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        nome = json['nome'] as String?,
        email = json['email'] as String?,
        senha = json['senha'] as String?,
        image = json['image'] as String?,
        cpf = json['cpf'] as String?,
        data_nascimento = _convertTimestamp(json['data_nascimento']);

  // Função auxiliar para converter Timestamp ou String para DateTime
  static DateTime? _convertTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // Método copyWith para criar uma nova instância com alterações
  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? senha,
    String? image,
    String? cpf,
    DateTime? data_nascimento,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      image: image ?? this.image,
      cpf: cpf ?? this.cpf,
      data_nascimento: data_nascimento ?? this.data_nascimento,
    );
  }
}
