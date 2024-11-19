import 'package:carhabty/rapples/EditRappelPage.dart';
import 'package:carhabty/rapples/DetailRappelPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../service/api_service.dart';

class Message extends StatefulWidget {
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  List<dynamic> rappels = [];
  bool isLoading = true; // Variable pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
    fetchRappels(); // Charge les rappels lors de l'initialisation
  }

  Future<void> fetchRappels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedVehicleId = prefs.getInt('selectedVehicleId');
    if (savedVehicleId != null) {
        final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
      try {
        final response = await http.get(Uri.parse('$url/rappels/$savedVehicleId'));

        if (response.statusCode == 200) {
          setState(() {
            rappels = json.decode(response.body);
            isLoading = false; // Désactiver l'indicateur de chargement
          });
        } else {
          throw Exception('Échec du chargement des rappels');
        }
      } catch (e) {
        setState(() {
          isLoading = false; // Désactiver l'indicateur de chargement même en cas d'erreur
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } else {
      setState(() {
        isLoading = false; // Désactiver l'indicateur de chargement si pas de véhicule sélectionné
      });
    }
  }

  Future<void> _deleteRappel(BuildContext context, int id) async {
    final response = await http.delete(Uri.parse('http://192.168.1.17:8000/api/rappeldelete/$id'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rappel supprimé avec succès")));
      setState(() {
        rappels.removeWhere((rappel) => rappel['id'] == id); // Supprimer localement le rappel
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de la suppression")));
    }
  }

  void _editRappel(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRappelPage(rappelId: id),
      ),
    ).then((_) {
      fetchRappels(); // Rafraîchir la liste après modification
    });
  }

  void _showDetails(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RappelDetailPage(rappelId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Afficher l'indicateur de chargement
          : rappels.isEmpty
              ? Center(child: Text("Aucun rappel disponible")) // Afficher un message si la liste est vide
              : ListView.builder(
                  itemCount: rappels.length,
                  itemBuilder: (context, index) {

                    final rappel = rappels[index];
                    final type = rappel['type'];
                    final typeIcon = type == 'depense' ? Icons.attach_money : Icons.build;

                     // Calcul de la différence de jours entre la date du rappel et aujourd'hui
                    DateTime dateRappel = DateTime.parse(rappel['date']);
                    DateTime now = DateTime.now();
                    int daysDifference = dateRappel.difference(now).inDays;
                    bool isPast = daysDifference < 0;

                    // Formatage de la date et message de différence en jours
                    String formattedDate = DateFormat('yyyy-MM-dd').format(dateRappel);
                    String daysInfo = isPast
                        ? "Il y a ${daysDifference.abs()} jours"
                        : "Reste $daysDifference jours";

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: Icon(typeIcon, color: Colors.blue),
                        title: Text("Rappel", style: TextStyle(color:  const Color.fromARGB(255, 33, 36, 33)),),
                        subtitle: Text(
                          "Type: $type\nDate: $formattedDate\n$daysInfo",
                          style: TextStyle(color: isPast ? Colors.red : Colors.green),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editRappel(context, rappel['id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteRappel(context, rappel['id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () => _showDetails(context, rappel['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
