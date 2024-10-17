
import 'package:carhabty/TypeEntretien/addpage.dart';
import 'package:carhabty/TypeEntretien/editpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fonction pour supprimer un type de dépense depuis le serveur
Future<void> deleteTypeEntretien(int id) async {
  final response = await http.delete(
    Uri.parse('http://192.168.1.113:8000/api/typeentretiens/$id'), // Remplacez par l'URL de votre API avec l'ID du type de dépense
  );

  if (response.statusCode != 200) {
    throw Exception('Échec de la suppression du type de entretien');
  }
}


// Page pour afficher les types de dépenses
class AfficherTypeEntretienPage extends StatefulWidget {
  @override
  _AfficherTypeentretienPageState createState() => _AfficherTypeentretienPageState();
}

class _AfficherTypeentretienPageState extends State<AfficherTypeEntretienPage> {
  List<dynamic> _typesEntretien = []; // Liste contenant les objets avec id et name
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Appel à la fonction pour récupérer les types de dépense lors de l'initialisation de la page
    fetchTypesEntretien().then((types) {
      setState(() {
        _typesEntretien = types;
        _isLoading = false;
      });
    });
  }

  // Fonction pour récupérer les types de dépenses depuis une API
  Future<List<dynamic>> fetchTypesEntretien() async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/typeentretiens')); // Remplacez par l'URL de votre API

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retourne la liste des types de dépense
    } else {
      throw Exception('Échec du chargement des types de entretien');
    }
  }

  // Fonction pour supprimer un type de dépense
  void _deleteTypeDepense(int id, int index) async {
    try {
      await deleteTypeEntretien(id); // Supprime le type de dépense côté serveur
      setState(() {
        _typesEntretien.removeAt(index); // Supprime localement après la suppression côté serveur
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de la suppression')));
    }
  }

  void _navigateToAddTypeEntretien() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTypeEntretienPage()), // Remplacez par le nom de votre page d'ajout
    );

    if (result == true) {
      // Rechargez les types de dépenses après l'ajout
      setState(() {
        _isLoading = true;
      });
      final types = await fetchTypesEntretien(); // Recharger la liste
      setState(() {
        _typesEntretien = types;
        _isLoading = false;
      });
    }
  }
  // Fonction pour naviguer vers la page d'édition
  void _navigateToEditPage(Map<String, dynamic> typeEntretien, int index) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditTypeEntretienPage(typeEntretien: typeEntretien)),
  );

  

  if (result == true) {
    setState(() {
      _typesEntretien[index]['name'] = typeEntretien['name']; // Met à jour la liste avec le nouveau nom
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Types de Entretien'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement pendant la récupération des données
          : ListView.builder(
              itemCount: _typesEntretien.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_typesEntretien[index]['name']), // Affiche le nom de chaque type de dépense
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     IconButton(
  icon: Icon(Icons.edit, color: Colors.blue), // Icône d'édition
  onPressed: () => _navigateToEditPage(_typesEntretien[index], index), // Appel à la fonction pour aller à la page d'édition
),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red), // Icône de suppression
                        onPressed: () => _deleteTypeDepense(_typesEntretien[index]['id'], index), // Appel à la fonction de suppression
                      ),
                    ],
                  ),
                );
              },
            ),
             floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTypeEntretien, // Appel à la fonction pour naviguer vers la page d'ajout
        child: Icon(Icons.add), // Icône d'ajout
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Page d'édition fictive
