import 'package:carhabty/home.dart';
import 'package:carhabty/models/vehicule.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditVehiculePage extends StatefulWidget {
  @override
  _EditVehiculePageState createState() => _EditVehiculePageState();
}

class _EditVehiculePageState extends State<EditVehiculePage> {
  final _formKey = GlobalKey<FormState>();
  Vehicule? vehicule;
  int? vehiculeId;

  @override
  void initState() {
    super.initState();
    _loadVehiculeId();
  }

  Future<void> _loadVehiculeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('selectedVehicleId');

    if (id != null) {
      setState(() {
        vehiculeId = id;
      });
      _loadVehiculeData(id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID de véhicule non trouvé dans les préférences.')));
    }
  }

  Future<void> _loadVehiculeData(int id) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles/$id/edit'));

      if (response.statusCode == 200) {
        setState(() {
          vehicule = Vehicule.fromJson(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to load vehicle data');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors du chargement des données')));
    }
  }

  Future<void> _updateVehicule() async {
    if (vehicule != null) {
      try {
        final response = await http.put(
          Uri.parse('http://192.168.1.113:8000/api/vehicles/${vehicule!.id}/update'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(vehicule!.toJson()),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Véhicule mis à jour')));
             SharedPreferences prefs = await SharedPreferences.getInstance();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Spincircle()),
      );
        } else {
           // Affichez le code de statut et le corps de la réponse pour le débogage
    print('Erreur lors de la mise à jour : ${response.statusCode} - ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour : ${response.body}')));
          throw Exception('Failed to update vehicle');
          
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vehicule == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Modifier le véhicule')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le véhicule'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                initialValue: vehicule!.nomV,
                decoration: InputDecoration(labelText: 'Nom du véhicule'),
                onChanged: (value) => vehicule!.nomV = value,
              ),
              DropdownButtonFormField(
                value: vehicule!.marque,
                decoration: InputDecoration(labelText: 'Marque'),
                items: [
                  'Peugeot',
                  'Renault',
                  'Citroën',
                  'Volkswagen',
                  'Mercedes',
                  'Toyota',
                  'BMW'
                ].map((String marque) {
                  return DropdownMenuItem(value: marque, child: Text(marque));
                }).toList(),
                onChanged: (value) => setState(() {
                  vehicule!.marque = value.toString();
                }),
              ),
              TextFormField(
                initialValue: vehicule!.modele,
                decoration: InputDecoration(labelText: 'Modèle'),
                onChanged: (value) => vehicule!.modele = value,
              ),
              TextFormField(
                initialValue: vehicule!.kilometrage.toString(), // Convertir le double en string pour afficher
                decoration: InputDecoration(labelText: 'Kilométrage'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Convertir le string en double et assigner à la propriété kilometrage
                  vehicule!.kilometrage = (double.tryParse(value) ?? 0.0) as String?; // Assurez-vous que la propriété kilometrage est de type double
                },
              ),
              TextFormField(
                initialValue: vehicule!.immatriculation,
                decoration: InputDecoration(labelText: 'Immatriculation'),
                onChanged: (value) => vehicule!.immatriculation = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateVehicule();
                  }
                },
                child: Text('Sauvegarder les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
