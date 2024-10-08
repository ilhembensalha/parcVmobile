import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RappelDetailPage extends StatefulWidget {
  final int rappelId;

  RappelDetailPage({required this.rappelId});

  @override
  _RappelDetailPageState createState() => _RappelDetailPageState();
}

class _RappelDetailPageState extends State<RappelDetailPage> {
  Map<String, dynamic> rappelDetails = {};
  String typeDepenseName = 'Type de dépense inconnu';
  String typeEntretienName = 'Type d\'entretien inconnu';

  @override
  void initState() {
    super.initState();
    _loadRappelDetails();
  }

  Future<void> _loadRappelDetails() async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/rappel/${widget.rappelId}'));

    if (response.statusCode == 200) {
      setState(() {
        rappelDetails = json.decode(response.body)['rappel'];
      });

      // Vérifiez si les IDs ne sont pas nuls avant de charger les noms
      if (rappelDetails['typeDepense'] != null) {
        await _loadTypeDepenseName(rappelDetails['typeDepense']);
      }

      if (rappelDetails['typeEntretien'] != null) {
        await _loadTypeEntretienName(rappelDetails['typeEntretien']);
      }
    } else {
      throw Exception('Erreur lors du chargement des détails du rappel');
    }
  }

  Future<void> _loadTypeDepenseName(int typeId) async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/typeDepense/$typeId'));

    if (response.statusCode == 200) {
      setState(() {
        typeDepenseName = json.decode(response.body)['name'] ?? 'Nom de dépense non disponible'; // Ajout d'une vérification
      });
    } else {
      throw Exception('Erreur lors du chargement du type de dépense');
    }
  }

  Future<void> _loadTypeEntretienName(int typeId) async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/typeEntretien/$typeId'));

    if (response.statusCode == 200) {
      setState(() {
        typeEntretienName = json.decode(response.body)['name'] ?? 'Nom d\'entretien non disponible'; // Ajout d'une vérification
      });
    } else {
      throw Exception('Erreur lors du chargement du type d\'entretien');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Rappel'),
      ),
      body: rappelDetails.isEmpty 
          ? Center(child: CircularProgressIndicator()) // Affichage d'un indicateur de chargement
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remarque:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(rappelDetails['remarque']?.toString() ?? 'Aucune remarque disponible', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  Text(
                    'Type:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(rappelDetails['type']?.toString() ?? 'Type inconnu', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  Text(
                    'Date:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(rappelDetails['date']?.toString() ?? 'Aucune date disponible', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  if (rappelDetails['kilometrage'] != null) ...[
                    Text(
                      'Kilométrage:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text('${rappelDetails['kilometrage']} km', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 15),
                  ],
                  Text(
                    'Type de Dépense:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(typeDepenseName, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  Text(
                    'Type d\'Entretien:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(typeEntretienName, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                ],
              ),
            ),
    );
  }
}
