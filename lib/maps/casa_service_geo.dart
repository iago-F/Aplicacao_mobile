import 'package:cloud_firestore/cloud_firestore.dart';
import 'geocoding_service.dart';

class casaServiceGeo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeocodingService _geocodingService;

  casaServiceGeo(String apiKey) : _geocodingService = GeocodingService(apiKey);

  Future<List<Map<String, dynamic>>> getCasasWithCoordinates() async {
    final casasSnapshot = await _firestore.collection('casas').get();
    List<Map<String, dynamic>> casasWithCoords = [];

    for (var casa in casasSnapshot.docs) {
      final data = casa.data();
      final endereco = '${data['rua']}, ${data['cidade']}, ${data['uf']}';

      final coordinates =
          await _geocodingService.getCoordinatesFromAddress(endereco);
      if (coordinates != null) {
        casasWithCoords.add({
          'id': casa.id,
          'endereco': endereco,
          'lat': coordinates['lat'],
          'lng': coordinates['lng'],
        });
      }
    }

    return casasWithCoords;
  }
}
