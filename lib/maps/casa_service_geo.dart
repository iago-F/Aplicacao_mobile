import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para buscar casas do Firestore
  Future<List<Map<String, dynamic>>> fetchCasas() async {
    try {
      // Busca as casas no Firestore
      QuerySnapshot snapshot = await _firestore.collection('casas').get();

      List<Map<String, dynamic>> casas = [];

      // Criar uma lista de futures para as requisições de coordenadas
      List<Future<void>> tasks = snapshot.docs.map((doc) async {
        var data = doc.data() as Map<String, dynamic>;

        // Obtém os componentes do endereço
        var rua = data['rua'] ?? '';
        var bairro = data['bairro'] ?? '';
        var estado = data['estado'] ?? '';
        var cidade = data['cidade'] ?? '';

        // Concatena os componentes do endereço
        var enderecoCompleto = '$cidade, $bairro, $estado, $rua';

        try {
          // Converte o endereço completo para lat/lon
          var latLon = await getLatLonFromEndereco(enderecoCompleto);

          // Adiciona as informações na lista de casas
          casas.add({
            'endereco': enderecoCompleto,
            'latitude': latLon['latitude'],
            'longitude': latLon['longitude'],
          });
        } catch (e) {
          print(
              "Erro ao obter coordenadas para o endereço: $enderecoCompleto. Erro: $e");
        }
      }).toList();

      // Aguarda todas as requisições de coordenadas
      await Future.wait(tasks);

      return casas;
    } catch (e) {
      throw Exception("Erro ao buscar casas do Firestore: $e");
    }
  }

  // Método para converter endereço em latitude e longitude
  Future<Map<String, double>> getLatLonFromEndereco(String endereco) async {
    const String apiKey =
        'AIzaSyBbPt8LEVqZ2jWwK2DmvQgmwQsFFYkNVcM'; // Substitua pela sua chave de API do Google

    // URL da API do Google Geocoding
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$endereco&key=$apiKey');

    try {
      // Realiza a requisição para a API
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'latitude': location['lat'],
            'longitude': location['lng'],
          };
        } else {
          throw Exception("Endereço não encontrado ou resposta inesperada.");
        }
      } else {
        throw Exception(
            "Erro ao acessar a API de Geocoding. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro na requisição de geocodificação: $e");
    }
  }
}
