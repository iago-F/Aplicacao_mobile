import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aluguel/maps/casa_service_geo.dart';
import 'package:aluguel/HomePage/casa_detalhes_page.dart'; // Importe a página CasaDetalhesPage
import 'package:aluguel/casa/casa_model.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = Set<Marker>();
  final GeocodingService _geocodingService = GeocodingService();
  BitmapDescriptor? customIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _loadHouses();
  }

  // Carregar o ícone personalizado
  void _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(40, 40)), // A configuração da imagem
      'assets/images/LOGO_CASA_PRINCIPAL.PNG', // Caminho para a imagem no seu diretório de assets
    ); // Carregar o ícone personalizado
  }

  void _loadHouses() async {
    try {
      final casasData = await _geocodingService.fetchCasas();
      for (var casaData in casasData) {
        if (casaData['latitude'] != null && casaData['longitude'] != null) {
          Casa casa = Casa.fromJson(
              casaData); // Passa o mapa completo para a classe Casa
          _addMarker(
              casa.latitude!.toDouble(), casa.longitude!.toDouble(), casa);
        }
      }
    } catch (e) {
      print("Erro ao carregar casas: $e");
    }
  }

  void _addMarker(double lat, double lng, Casa casa) {
    print(
        "Adicionando marcador para a casa ${casa.id_casa}: Lat: $lat, Lng: $lng");
    if (customIcon != null) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(casa.id_casa.toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'Casa ${casa.id_casa}'),
          icon: customIcon!,
          onTap: () {
            // Navegar para a página de detalhes da casa, passando o objeto Casa
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CasaDetalhesPage(
                  casa:
                      casa, // Passando o objeto Casa para a página de detalhes
                ),
              ),
            );
          },
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-15.6010, -56.0979), // Cuiabá como ponto inicial
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
