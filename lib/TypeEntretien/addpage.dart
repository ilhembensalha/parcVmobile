import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Page pour ajouter un type de dépense
class AddTypeEntretienPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // Fonction pour ajouter un type de dépense
  Future<void> addTypeDepense(String name) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.113:8000/api/typeentretiens'), // Remplacez par l'URL de votre API
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 201) {
      throw Exception('Échec de l\'ajout du type de entretien');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Type de Entretien'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom du type de entretien'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await addTypeDepense(_nameController.text); // Appelle la fonction pour ajouter
                      Navigator.pop(context, true); // Retourne à la page précédente avec succès
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'ajout')));
                    }
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}