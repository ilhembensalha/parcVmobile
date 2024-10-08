import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  Future<List<Vehicule>> fetchVehicles() async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map<Vehicule>((vehicle) => Vehicule.fromJson(vehicle)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<void> _saveSelectedVehicleId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedVehicleId', id);
  }

  Future<int?> _loadSelectedVehicleId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedVehicleId');
  }

  Future<Map<String, dynamic>> fetchVehicleData(int vehicleId) async {
    
    try {

      final depenseResponse = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles/$vehicleId/expenses'));
      final fuelResponse = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles/$vehicleId/fuel'));
      final maintenanceResponse = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles/$vehicleId/maintenance'));

      if (depenseResponse.statusCode == 200 &&
          fuelResponse.statusCode == 200 &&
          maintenanceResponse.statusCode == 200) {
               print('good');
        return {
          'expenses': (json.decode(depenseResponse.body) as List)
              .map((e) => Depense.fromJson(e))
              .toList(),
          'fuel': (json.decode(fuelResponse.body) as List)
              .map((e) => Carburant.fromJson(e))
              .toList(),
          'maintenance': (json.decode(maintenanceResponse.body) as List)
              .map((e) => Entretien.fromJson(e))
              .toList(),
           
        };

      } else {
        throw Exception('Failed to load vehicle data');
      }
    } catch (e) {
      throw Exception('Error fetching vehicle data: $e');
    }
  }

  List<dynamic> sortByDate(List<dynamic> data) {
    data.sort((a, b) {
      DateTime dateA = DateTime.parse(a.date);
      DateTime dateB = DateTime.parse(b.date);
      return dateB.compareTo(dateA); // Inversion pour avoir les dates les plus récentes en premier
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Vehicule>>(
        future: fetchVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final vehicles = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  FutureBuilder<int?>(
                    future: _loadSelectedVehicleId(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        final selectedVehicleId = snapshot.data;
                        Vehicule? selectedVehicle;

                        if (selectedVehicleId != null) {
                          selectedVehicle = vehicles.firstWhere(
                              (vehicle) => vehicle.id == selectedVehicleId,
                              orElse: () => vehicles.first);
                        }

                        return DropdownSearch<Vehicule>(
                          items: vehicles,
                          itemAsString: (Vehicule vehicle) => vehicle.nomV,
                          selectedItem: selectedVehicle,
                          onChanged: (Vehicule? vehicle) {
                            if (vehicle != null) {
                              _saveSelectedVehicleId(vehicle.id);
                            }
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Sélectionner un véhicule",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: "Rechercher un véhicule",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        );
                      }
                      return const Text('Aucun véhicule sélectionné');
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _loadSelectedVehicleId().then((id) => fetchVehicleData(id ?? 0)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Erreur : ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;
                          final expenses = sortByDate(data['expenses'] as List<Depense>);
                          final fuel = sortByDate(data['fuel'] as List<Carburant>);
                          final maintenance = sortByDate(data['maintenance'] as List<Entretien>);

                          // Combiner toutes les données pertinentes en une seule liste
                          final allEvents = [...expenses, ...fuel, ...maintenance];

                          return ListView(
                            children: sortByDate(allEvents).map((event) {
                              IconData icon;
                              String title;

                              // Déterminer le titre et l'icône en fonction du type d'événement
                              if (event is Depense) {
                                title = 'Dépense - Montant: ${event.montant}';
                                icon = Icons.attach_money; // Icône pour les dépenses
                              } else if (event is Carburant) {
                                title = 'Carburant - Remarque: ${event.remarque}';
                                icon = Icons.local_gas_station; // Icône pour le carburant
                              } else if (event is Entretien) {
                                title = 'Entretien - Détails: ${event.details}';
                                icon = Icons.build; // Icône pour l'entretien
                              } else {
                                title = 'Événement inconnu'; // Cas de sécurité
                                icon = Icons.error; // Icône pour les cas non identifiés
                              }

                              return ListTile(
                                leading: Icon(icon), // Ajouter l'icône correspondant au type d'événement
                                title: Text(title), // Afficher le nom spécifique à l'événement
                                subtitle: Text('Date: ${event.date}'), // Afficher la date de l'événement
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _editEvent(event);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteEvent(event);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.info),
                                      onPressed: () {
                                        _showDetails(event);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return const Text('Aucune donnée disponible');
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Text('Aucun véhicule trouvé');
          }
        },
      ),
    );
  }

  // Méthode pour afficher les détails d'un événement
  void _showDetails(dynamic event) {
    // Implémentation pour afficher les détails de l'événement
  }

  // Méthode pour éditer un événement
  void _editEvent(dynamic event) {
    // Implémentation de l'édition de l'événement
  }

  // Méthode pour supprimer un événement
  void _deleteEvent(dynamic event) {
    // Implémentation pour supprimer l'événement
  }
}

// Modèles des données

class Vehicule {
  final int id;
  final String nomV;
  final String marque;
  final String modele;
  final String type;
  final String status;
  final String immatriculation;
  final String? vin;
  final String? kilometrage;
  final String datePc;

  Vehicule({
    required this.id,
    required this.nomV,
    required this.marque,
    required this.modele,
    required this.type,
    required this.status,
    required this.immatriculation,
    this.vin,
    this.kilometrage,
    required this.datePc,
  });

  factory Vehicule.fromJson(Map<String, dynamic> json) {
    return Vehicule(
      id: json['id'],
      nomV: json['nomV'],
      marque: json['marque'],
      modele: json['modele'],
      type: json['type'],
      status: json['status'],
      immatriculation: json['immatriculation'],
      vin: json['vin'],
      kilometrage: json['kilometrage'],
      datePc: json['datePc'],
    );
  }
}

class Depense {
  final int id;
  final int montant;
  final String date;

  Depense({required this.id, required this.montant, required this.date});

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      montant: json['montant'],
      date: json['date'],
    );
  }
}

class Carburant {
  final int id;
  final String remarque;
  final String date;

  Carburant({required this.id, required this.remarque, required this.date});

  factory Carburant.fromJson(Map<String, dynamic> json) {
    return Carburant(
      id: json['id'] ?? 0,
      remarque: json['remarque'] ?? 'Pas de remarque',
      date: json['date'] ?? 'Date inconnue',
    );
  }
}

class Entretien {
  final int id;
  final String details;
  final String date;

  Entretien({required this.id, required this.details, required this.date});

  factory Entretien.fromJson(Map<String, dynamic> json) {
    return Entretien(
          id: json['id'] ?? 0,
      details: json['details'] ?? 'Pas de détails',
      date: json['date'] ?? 'Date inconnue',
    );
  }
}
