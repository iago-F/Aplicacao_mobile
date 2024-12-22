class Casa {
  String? id_casa;
  String? id_usuario;
  String? imagem;
  String? rua;
  String? bairro;
  String? cep; // Novo campo adicionado
  String? cidade;
  String? estado;
  String? descricao;
  double? area;
  double? preco_total;
  int? num_banheiro;
  int? num_quarto;

  // Construtor
  Casa({
    this.id_casa,
    this.id_usuario,
    this.imagem,
    this.rua,
    this.bairro,
    this.cep, // Novo campo incluído no construtor
    this.cidade,
    this.estado,
    this.descricao,
    this.area,
    this.preco_total,
    this.num_banheiro,
    this.num_quarto,
  });

  // Converte um objeto Casa para um mapa (necessário para salvar no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id_casa': id_casa,
      'id_usuario': id_usuario,
      'imagem': imagem,
      'rua': rua,
      'bairro': bairro,
      'cep': cep, // Adicionado ao método toJson
      'cidade': cidade,
      'estado': estado,
      'descricao': descricao,
      'area': area,
      'preco_total': preco_total,
      'num_banheiro': num_banheiro,
      'num_quarto': num_quarto,
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
      cep: json['cep'], // Adicionado ao construtor factory
      cidade: json['cidade'],
      estado: json['estado'],
      descricao: json['descricao'],
      area: json['area'],
      preco_total: json['preco_total'],
      num_banheiro: json['num_banheiro'],
      num_quarto: json['num_quarto'],
    );
  }
}
