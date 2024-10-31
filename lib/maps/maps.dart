import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapsPage extends StatefulWidget {

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  LatLng? _vehicleLocation;
  String _address = "Chargement de l'adresse...";

  @override
  void initState() {
    super.initState();
    _fetchVehicleLocation();
  }

  Future<void> _fetchVehicleLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('selectedVehicleId');
    final url = Uri.parse('http://192.168.1.113:8000/api/vehicles/${id}/location');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _vehicleLocation = LatLng(data['latitude'], data['longitude']);
        });
        _fetchAddress(data['latitude'], data['longitude']);
      } else {
        print("Échec de chargement de la localisation du véhicule.");
      }
    } catch (e) {
      print("Erreur de connexion: $e");
    }
  }

  Future<void> _fetchAddress(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _address = data['display_name'] ?? 'Adresse non trouvée';
        });
      } else {
        print("Échec de chargement de l'adresse.");
      }
    } catch (e) {
      print("Erreur de chargement de l'adresse: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: _vehicleLocation ?? LatLng(33.0, 7.0), // Position par défaut
                zoom: 6.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_vehicleLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _vehicleLocation!,
                        builder: (ctx) => Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  SizedBox(height: 10),
                Text(
                  _address,
                  style: TextStyle(fontSize: 16),
                ),
                  SizedBox(height: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
