import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aluguel/maps/casa_service_geo.dart';

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
      final casas = await _geocodingService.fetchCasas();
      for (var casa in casas) {
        if (casa['latitude'] != null && casa['longitude'] != null) {
          _addMarker(casa['latitude'], casa['longitude'], casa['endereco']);
        }
      }
    } catch (e) {
      print("Erro ao carregar casas: $e");
    }
  }

  // Função para adicionar marcador no mapa
  // Função para adicionar marcador no mapa com o ícone customizado
  void _addMarker(double lat, double lng, String houseId) {
    print("Adicionando marcador para a casa $houseId: Lat: $lat, Lng: $lng");
    if (customIcon != null) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(houseId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'Casa $houseId'),
          icon: customIcon!, // Usando o ícone personalizado
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
