import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String apiKey;

  GeocodingService(this.apiKey);

  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'],
            'lng': location['lng'],
          };
        } else {
          return null; // Endereço não encontrado
        }
      } else {
        throw Exception('Falha ao buscar coordenadas: ${response.body}');
      }
    } catch (e) {
      print('Erro: $e');
      return null;
    }
  }
}
