class Casa {
  String? id_casa;
  String? id_usuario;
  String? imagem;
  String? rua;
  String? bairro;
  String? cidade;
  String? estado;
  String? descricao;
  double? area;
  double? preco_total;
  int? num_banheiro;
  //num_quartos --> implementar

  // Construtor
  Casa({
    this.id_casa,
    this.id_usuario,
    this.imagem,
    this.rua,
    this.bairro,
    this.cidade,
    this.estado,
    this.descricao,
    this.area,
    this.preco_total,
    this.num_banheiro,
  });

  // Converte um objeto Casa para um mapa (necessário para salvar no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id_casa': id_casa,
      'id_usuario': id_usuario,
      'imagem': imagem,
      'rua': rua,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'descricao': descricao,
      'area': area,
      'preco_total': preco_total,
      'num_banheiro': num_banheiro,
    };
  }

  // Construtor para criar uma instância de Casa a partir de um mapa
  factory Casa.fromJson(Map<String, dynamic> json) {
    return Casa(
      id_casa: json['id_casa'],
      id_usuario: json['id_usuario'],
      imagem: json['imagem'],
      rua: json['rua'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
      descricao: json['descricao'],
      area: json['area'],
      preco_total: json['preco_total'],
      num_banheiro: json['num_banheiro'],
    );
  }
}
