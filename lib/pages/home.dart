import 'package:carhabty/DetailCarburantPage.dart';
import 'package:carhabty/DetailDepensePage.dart';
import 'package:carhabty/DetailEntretienPage%20.dart';
import 'package:carhabty/EditCarburantPage.dart';
import 'package:carhabty/EditDepensePage.dart';
import 'package:carhabty/EditEntretienPage.dart';
import 'package:carhabty/EditRappelPage.dart';
import 'package:carhabty/RappelDetailPage.dart';
import 'package:carhabty/models/Carburant.dart';
import 'package:carhabty/models/Depense.dart';
import 'package:carhabty/models/Entretien.dart';
import 'package:carhabty/models/Rappel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Vehicule> vehicles = [];
  Vehicule? selectedVehicle;
  List<Depense> expenses = [];
  List<Carburant> fuel = [];
  List<Entretien> maintenance = [];
   List<Rappel> rappels = [];
 

  @override
  void initState() {
    super.initState();
    fetchVehicles(); // Récupère la liste des véhicules à l'initialisation
  }

  // Fonction pour récupérer la liste des véhicules depuis l'API
  Future<void> fetchVehicles() async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        vehicles = jsonResponse.map((vehicle) => Vehicule.fromJson(vehicle)).toList();
      });
      // Charger l'ID du véhicule sélectionné après avoir récupéré la liste des véhicules
      _loadSelectedVehicle();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  // Sauvegarde l'ID du véhicule sélectionné dans le local storage
  Future<void> _saveSelectedVehicleId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedVehicleId', id);
  }

  // Récupère l'ID du véhicule sélectionné depuis le local storage
  Future<void> _loadSelectedVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedVehicleId = prefs.getInt('selectedVehicleId');

    if (savedVehicleId != null && vehicles.isNotEmpty) {
      // Trouve le véhicule correspondant dans la liste
      Vehicule? foundVehicle = vehicles.firstWhere(
          (vehicle) => vehicle.id == savedVehicleId,
          );

      // Met à jour le véhicule sélectionné seulement si trouvé
      if (foundVehicle != null) {
        setState(() {
          selectedVehicle = foundVehicle;
        });
        // Charger les données associées au véhicule sélectionné
        fetchVehicleData(foundVehicle.id);
      }
    }
  }

 Future<Map<String, dynamic>> fetchVehicleData(int vehicleId) async {
  
    try {

      final depenseResponse = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles/$vehicleId/expenses'));
      final fuelResponse = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles/$vehicleId/fuel'));
      final maintenanceResponse = await http.get(Uri.parse('http://192.168.1.113:8000/api/vehicles/$vehicleId/maintenance'));
      final rappelResponse = await http.get(Uri.parse('http://192.168.1.113:8000/api/rappels/$vehicleId'));
      if (depenseResponse.statusCode == 200 &&
          fuelResponse.statusCode == 200 &&
          maintenanceResponse.statusCode == 200 &&
          rappelResponse.statusCode == 200
          ) {
               print('good');
        return {
          'expenses': (json.decode(depenseResponse.body) as List)
              .map((e) => Depense.fromJson(e))
              .toList() ?? [],
          'fuel': (json.decode(fuelResponse.body) as List)
              .map((e) => Carburant.fromJson(e))
              .toList() ?? [],
          'maintenance': (json.decode(maintenanceResponse.body) as List)
              .map((e) => Entretien.fromJson(e))
              .toList() ?? [],
               'rappel': (json.decode(rappelResponse.body) as List)
              .map((e) => Rappel.fromJson(e))
              .toList() ?? [],
           
        };

      } else {
        throw Exception('Failed to load vehicle data');
      }
    } catch (e) {
      throw Exception('Error fetching vehicle data: $e');
    } 

 }
  // Fonction appelée lorsque l'utilisateur sélectionne un véhicule
  void _onVehicleSelected(Vehicule? vehicle) {
    setState(() {
      selectedVehicle = vehicle;
    });
    if (vehicle != null) {
      _saveSelectedVehicleId(vehicle.id); // Sauvegarde l'ID du véhicule sélectionné
      fetchVehicleData(vehicle.id); // Charge les données du véhicule sélectionné
    }
  }
  Future<int?> _loadSelectedVehicleId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedVehicleId');
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
      body: vehicles.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Affiche un spinner pendant le chargement
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownSearch<Vehicule>(
                    items: vehicles, // Liste des véhicules
                    itemAsString: (Vehicule vehicle) => vehicle.marque, // Affichage du nom du véhicule
                    selectedItem: selectedVehicle, // L'élément sélectionné
                    onChanged: _onVehicleSelected, // Action lors de la sélection
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Sélectionner un véhicule",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true, // Activer la recherche
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: "Rechercher un véhicule",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Affiche les détails du véhicule sélectionné
                  selectedVehicle == null
                      ? const Text('Aucun véhicule sélectionné')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                         
                            // Affiche d'autres informations si nécessaire
                          ],
                        ),
                  const SizedBox(height: 20),
                  // Afficher les données récupérées
                 
                    Expanded(
  child: FutureBuilder<Map<String, dynamic>>(
    future: _loadSelectedVehicleId().then((id) => fetchVehicleData(id ?? 0)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(
          child: Text('Erreur : ${snapshot.error}'),
        );
      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        final data = snapshot.data!;
        final expenses = sortByDate(data['expenses'] as List<Depense>);
        final fuel = sortByDate(data['fuel'] as List<Carburant>);
        final maintenance = sortByDate(data['maintenance'] as List<Entretien>);
        final rappels = sortByDate(data['rappel'] as List<Rappel>);
        
        // Combiner toutes les données pertinentes en une seule liste
        final allEvents = [...expenses, ...fuel, ...maintenance, ...rappels];
        
        if (allEvents.isEmpty) {
          return const Center(child: Text('Aucun événement disponible.'));
        }

        return ListView(
          children: allEvents.map((event) {
            String title;
            IconData icon;
            
            // Déterminer le type d'événement et configurer l'icône et le titre appropriés
            if (event is Depense) {
              title = event.montant != null ? 'Dépense - Montant: ${event.montant}' : 'Dépense';
              icon = Icons.attach_money;
            } else if (event is Carburant) {
              title = event.remarque != null ? 'Carburant - Remarque: ${event.remarque}' : 'Carburant';
              icon = Icons.local_gas_station;
            } else if (event is Entretien) {
              title = event.date != null ? 'Entretien - Date: ${event.date}' : 'Entretien';
              icon = Icons.build;
            } else if (event is Rappel) {
              title = event.date != null ? 'Rappel - Date: ${event.date}' : 'Rappel';
              icon = Icons.watch;
            } else {
              title = 'Événement inconnu';
              icon = Icons.error;
            }

            return ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text('Date: ${event.date}'),
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
        return const Center(child: Text('Aucune donnée disponible'));
      }
    },
  ),
),

                ],
              ),
            ),
    );
  }

  
  // Méthode pour afficher les détails d'un événement
  void _showDetails(dynamic event) {
    // Implémentation pour afficher les détails de l'événement
      if (event is Depense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailDepensePage (depense: event),
      ),
    );
  } else if (event is Carburant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCarburantPage(carburant: event),
      ),
    );
  } else if (event is Entretien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailEntretienPage (entretien: event),
      ),
    );
  }
   else if (event is Rappel) {
 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RappelDetailPage(rappelId: event.id),
      ),
    );
  }
  }

void _editEvent(dynamic event) {
  if (event is Depense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDepensePage(depense: event),
      ),
    );
  } else if (event is Carburant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCarburantPage(carburant: event),
      ),
    );
  } else if (event is Entretien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntretienPage(entretien: event),
      ),
    );
  }
  else if (event is Rappel) {
 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRappelPage(rappelId: event.id),
      ),
    );
  }
}


  // Méthode pour supprimer un événement
void _deleteEvent(dynamic event) async {
  String url = '';
  if (event is Depense) {
    url = 'http://192.168.1.113:8000/api/expensesdelete/${event.id}';
    print('depense suuprime');
  } else if (event is Carburant) {
    url = 'http://192.168.1.113:8000/api/fueldelete/${event.id}';
      print('Carburant suuprime');
  } else if (event is Entretien) {
    url = 'http://192.168.1.113:8000/api/maintenancedelete/${event.id}';
      print('Entretien suuprime');
  }
   else if (event is Rappel) {
    url = 'http://192.168.1.113:8000/api/rappeldelete/${event.id}';
      print('Rappel suuprime');
  }

  final response = await http.delete(Uri.parse(url));

  if (response.statusCode == 200) {
    print('Événement supprimé');
    setState(() {
      // Retirer l'événement supprimé de la liste
      if (event is Depense) {
        expenses.remove(event);
      } else if (event is Carburant) {
        fuel.remove(event);
      } else if (event is Entretien) {
        maintenance.remove(event);
      }else if (event is Rappel) {
        rappels.remove(event);
      }
    });
  } else {
    throw Exception('Échec de la suppression');
  }
}

}

// Modèle de données pour le véhicule



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
  final List<Entretien> fuel;
  final List<Depense> expenses;
  final List<Carburant> maintenance;

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
    required this.fuel,
    required this.expenses,
    required this.maintenance,
  });

  factory Vehicule.fromJson(Map<String, dynamic> json) {
    return Vehicule(
      id: json['id'] ?? 0,
      nomV: json['nomV'] ?? 'Nom inconnu',
      marque: json['marque'] ?? 'Marque inconnue',
      modele: json['modele'] ?? 'Modèle inconnu',
      type: json['type'] ?? 'Type inconnu',
      status: json['status'] ?? 'Statut inconnu',
      immatriculation: json['immatriculation'] ?? 'Immatriculation inconnue',
      vin: json['vin'],
      kilometrage: json['kilometrage']?.toString(),
      datePc: json['datePc'] ?? 'Date inconnue',
      fuel: (json['fuel'] as List?)?.map((i) => Entretien.fromJson(i)).toList() ?? [],
      expenses: (json['expenses'] as List?)?.map((i) => Depense.fromJson(i)).toList() ?? [],
      maintenance: (json['maintenance'] as List?)?.map((i) => Carburant.fromJson(i)).toList() ?? [],
    );
  }
}



