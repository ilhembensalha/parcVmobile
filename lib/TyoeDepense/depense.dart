import 'package:carhabty/TyoeDepense/addpage.dart';
import 'package:carhabty/TyoeDepense/editPage.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fonction pour supprimer un type de dépense depuis le serveur
Future<void> deleteTypeDepense(int id) async {
    final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
  final response = await http.delete(
    Uri.parse('$url/typedepenses/$id'), // Remplacez par l'URL de votre API avec l'ID du type de dépense
  );

  if (response.statusCode != 200) {
    throw Exception('Échec de la suppression du type de dépense');
  }
}


// Page pour afficher les types de dépenses
class AfficherTypeDepensePage extends StatefulWidget {
  @override
  _AfficherTypeDepensePageState createState() => _AfficherTypeDepensePageState();
}

class _AfficherTypeDepensePageState extends State<AfficherTypeDepensePage> {
  List<dynamic> _typesDepense = []; // Liste contenant les objets avec id et name
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Appel à la fonction pour récupérer les types de dépense lors de l'initialisation de la page
    fetchTypesDepense().then((types) {
      setState(() {
        _typesDepense = types;
        _isLoading = false;
      });
    });
  }

  // Fonction pour récupérer les types de dépenses depuis une API
  Future<List<dynamic>> fetchTypesDepense() async {
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    final response = await http.get(Uri.parse('$url/typedepenses')); // Remplacez par l'URL de votre API

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retourne la liste des types de dépense
    } else {
      throw Exception('Échec du chargement des types de dépense');
    }
  }

  // Fonction pour supprimer un type de dépense
  void _deleteTypeDepense(int id, int index) async {
    try {
      await deleteTypeDepense(id); // Supprime le type de dépense côté serveur
      setState(() {
        _typesDepense.removeAt(index); // Supprime localement après la suppression côté serveur
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de la suppression')));
    }
  }

  void _navigateToAddTypeDepense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTypeDepensePage()), // Remplacez par le nom de votre page d'ajout
    );

    if (result == true) {
      // Rechargez les types de dépenses après l'ajout
      setState(() {
        _isLoading = true;
      });
      final types = await fetchTypesDepense(); // Recharger la liste
      setState(() {
        _typesDepense = types;
        _isLoading = false;
      });
    }
  }
  // Fonction pour naviguer vers la page d'édition
  void _navigateToEditPage(Map<String, dynamic> typeDepense, int index) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditTypeDepensePage(typeDepense: typeDepense)),
  );

  

  if (result == true) {
    setState(() {
      _typesDepense[index]['name'] = typeDepense['name']; // Met à jour la liste avec le nouveau nom
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Types de Dépenses'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement pendant la récupération des données
          : ListView.builder(
              itemCount: _typesDepense.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_typesDepense[index]['name']), // Affiche le nom de chaque type de dépense
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     IconButton(
  icon: Icon(Icons.edit), // Icône d'édition
  onPressed: () => _navigateToEditPage(_typesDepense[index], index), // Appel à la fonction pour aller à la page d'édition
),
                      IconButton(
                        icon: Icon(Icons.delete), // Icône de suppression
                        onPressed: () => _deleteTypeDepense(_typesDepense[index]['id'], index), // Appel à la fonction de suppression
                      ),
                    ],
                  ),
                );
              },
            ),
             floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTypeDepense, // Appel à la fonction pour naviguer vers la page d'ajout
        child: Icon(Icons.add), // Icône d'ajout
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Page d'édition fictive
