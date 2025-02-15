class Casa {
  String? id_casa;
  String? id_usuario;
  List<String>? Imagem; // Alterado para uma lista de imagens
  String? rua;
  String? bairro;
  String? cep;
  String? cidade;
  String? estado;
  String? descricao;
  double? area;
  double? preco_total;
  int? num_banheiro;
  int? num_quarto;
  double? latitude;
  double? longitude;

  Casa({
    this.id_casa,
    this.id_usuario,
    this.Imagem, // Lista de imagens
    this.rua,
    this.bairro,
    this.cep,
    this.cidade,
    this.estado,
    this.descricao,
    this.area,
    this.preco_total,
    this.num_banheiro,
    this.num_quarto,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_casa': id_casa,
      'id_usuario': id_usuario,
      'imagens': Imagem, // Lista de imagens
      'rua': rua,
      'bairro': bairro,
      'cep': cep,
      'cidade': cidade,
      'estado': estado,
      'descricao': descricao,
      'area': area,
      'preco_total': preco_total,
      'num_banheiro': num_banheiro,
      'num_quarto': num_quarto,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Casa.fromJson(Map<String, dynamic> json) {
    return Casa(
      id_casa: json['id_casa'],
      id_usuario: json['id_usuario'],
      Imagem: List<String>.from(
          json['imagens'] ?? []), // Convertendo a lista de imagens
      rua: json['rua'],
      bairro: json['bairro'],
      cep: json['cep'],
      cidade: json['cidade'],
      estado: json['estado'],
      descricao: json['descricao'],
      area: json['area'],
      preco_total: json['preco_total'],
      num_banheiro: json['num_banheiro'],
      num_quarto: json['num_quarto'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
