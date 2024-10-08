import 'package:carhabty/models/Carburant.dart';
import 'package:carhabty/models/Depense.dart';
import 'package:carhabty/models/Entretien.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditEventPage extends StatefulWidget {
  final dynamic event;

  EditEventPage({required this.event});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  TextEditingController _montantController = TextEditingController();
  TextEditingController _remarqueController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _typeController = TextEditingController(); // Pour typeCarburant, typeEntretien, etc.
  TextEditingController _vehiculeController = TextEditingController();
  TextEditingController _conducteurController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialiser les champs en fonction du type d'événement
    if (widget.event is Depense) {
      _montantController.text = widget.event.montant.toString();
      _remarqueController.text = widget.event.remarque ?? '';
      _dateController.text = widget.event.date;
      _typeController.text = widget.event.typeDepense ?? '';
      _vehiculeController.text = widget.event.vehicule ?? '';
      _conducteurController.text = widget.event.conducteur ?? '';
      _imageController.text = widget.event.image ?? '';
    } else if (widget.event is Carburant) {
      _remarqueController.text = widget.event.remarque ?? '';
      _dateController.text = widget.event.date;
      _typeController.text = widget.event.typeCarburant ?? '';
      _vehiculeController.text = widget.event.vehicule ?? '';
      _conducteurController.text = widget.event.conducteur ?? '';
      _imageController.text = widget.event.image ?? '';
    } else if (widget.event is Entretien) {
      _remarqueController.text = widget.event.remarque ?? '';
      _dateController.text = widget.event.date;
      _typeController.text = widget.event.typeEntretien ?? '';
      _vehiculeController.text = widget.event.vehicule ?? '';
      _conducteurController.text = widget.event.conducteur ?? '';
      _imageController.text = widget.event.image ?? '';
    }
  }

  Future<void> _saveEditedEvent() async {
    String url = '';
    if (widget.event is Depense) {
      url = 'http://192.168.1.113:8000/api/expenses/${widget.event.id}';
    } else if (widget.event is Carburant) {
      url = 'http://192.168.1.113:8000/api/fuel/${widget.event.id}';
    } else if (widget.event is Entretien) {
      url = 'http://192.168.1.113:8000/api/maintenance/${widget.event.id}';
    }

    final data = jsonEncode(<String, dynamic>{
      'date': _dateController.text,
      if (widget.event is Depense) 'montant': int.parse(_montantController.text),
      'remarque': _remarqueController.text,
      'type': _typeController.text,
      'vehicule': _vehiculeController.text,
      'conducteur': _conducteurController.text,
      'image': _imageController.text,
    });

    print('Data envoyée : $data');

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: data,
    );

    if (response.statusCode == 200) {
      print('Événement mis à jour avec succès');
      Navigator.of(context).pop();
    } else {
      throw Exception('Échec de la mise à jour');
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _remarqueController.dispose();
    _dateController.dispose();
    _typeController.dispose();
    _vehiculeController.dispose();
    _conducteurController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier l\'événement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.event is Depense)
                TextFormField(
                  controller: _montantController,
                  decoration: InputDecoration(labelText: 'Montant'),
                  keyboardType: TextInputType.number,
                ),
              TextFormField(
                controller: _remarqueController,
                decoration: InputDecoration(labelText: 'Remarque'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: widget.event is Depense ? 'Type de dépense' : (widget.event is Carburant ? 'Type de carburant' : 'Type d\'entretien')),
              ),
              TextFormField(
                controller: _vehiculeController,
                decoration: InputDecoration(labelText: 'Véhicule'),
              ),
              TextFormField(
                controller: _conducteurController,
                decoration: InputDecoration(labelText: 'Conducteur'),
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEditedEvent,
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
