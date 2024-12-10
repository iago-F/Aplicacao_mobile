import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'casa_service_geo.dart';

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    carregarCasas();
  }

  void carregarCasas() async {
    final casaService = Provider.of<casaServiceGeo>(context, listen: false);
    final casas = await casaService.getCasasWithCoordinates();

    setState(() {
      for (var casa in casas) {
        _markers.add(
          Marker(
            markerId: MarkerId(casa['id']),
            position: LatLng(casa['lat'], casa['lng']),
            infoWindow: InfoWindow(title: casa['endereco']),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Casas'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              LatLng(-14.2350, -51.9253), // Posição inicial do mapa (Brasil)
          zoom: 4,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }
}
