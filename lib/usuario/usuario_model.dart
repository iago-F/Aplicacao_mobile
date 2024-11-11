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
    this.nome,
    this.email,
    this.senha,
    this.image,
    this.cpf,
    this.data_nascimento,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome, // Adicionei o nome para ser salvo também
      'email': email,
      'senha': senha,
      'image': image,
      'cpf': cpf,
      'data_nascimento': data_nascimento,
    };
  }

  // Construtor modificado para aceitar um Map<String, dynamic>
  Usuario.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'],
        email = json['email'],
        image = json['image'],
        cpf = json['cpf'],
        data_nascimento = (json['data_nascimento'] as Timestamp?)?.toDate();
}
