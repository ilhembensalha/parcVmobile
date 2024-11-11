import 'package:carhabty/TyoeDepense/depense.dart';
import 'package:carhabty/pagesRapports/depenserapport.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateTypeDepense(int id, String newName) async {
  try {
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    final response = await http.put(
      Uri.parse('$url/typedepenses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour du type de dépense');
    }
  } catch (e) {
    print('Erreur: $e');
    throw e;
  }
}


// Page d'édition pour modifier un type de dépense
class EditTypeDepensePage extends StatefulWidget {
  final Map<String, dynamic> typeDepense;

  EditTypeDepensePage({required this.typeDepense});

  @override
  _EditTypeDepensePageState createState() => _EditTypeDepensePageState();
}

class _EditTypeDepensePageState extends State<EditTypeDepensePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.typeDepense['name']); // Pré-remplit avec le nom actuel
  }

 void _submitChanges() async {
  if (_formKey.currentState!.validate()) {
    try {
      print('Essai de mise à jour avec le nom: ${_nameController.text}');
      await updateTypeDepense(widget.typeDepense['id'], _nameController.text);
   Navigator.pop(context, true);
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de la mise à jour')));
    }
  } else {
    print('Validation échouée');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Type de Dépense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom du type de dépense'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitChanges,
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
