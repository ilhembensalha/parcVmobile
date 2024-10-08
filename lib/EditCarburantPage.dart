import 'dart:convert';
import 'dart:io';
import 'package:carhabty/models/Carburant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditCarburantPage extends StatefulWidget {
  final Carburant carburant;

  EditCarburantPage({required this.carburant});

  @override
  _EditCarburantPageState createState() => _EditCarburantPageState();
}

class _EditCarburantPageState extends State<EditCarburantPage> {
  TextEditingController _remarqueController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _litreController = TextEditingController();
  TextEditingController _montantController = TextEditingController();
    String? _imageUrl;
     // Variable pour stocker l'URL de l'image existante


  final List<String> _typeCarburants = ["Essence", "Diesel", "Essence premium", "Ethanol", "Essence Moyenne"];
  String? _selectedTypeCarburant;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _remarqueController.text = widget.carburant.remarque;
    _dateController.text = widget.carburant.date;
    _litreController.text = widget.carburant.litre.toString();
    _montantController.text = widget.carburant.montant.toString();
    _selectedTypeCarburant = widget.carburant.typeCarburant;
    _imageUrl = widget.carburant.image; 
    print( _imageUrl);// Assurez-vous que l'URL de l'image est dans le modèle

  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.carburant.date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveCarburant() async {
    var uri = Uri.parse("http://192.168.1.113:8000/api/fuel/${widget.carburant.id}");

    var request = http.MultipartRequest("POST", uri);
    request.fields['date'] = _dateController.text;
    request.fields['remarque'] = _remarqueController.text;
    request.fields['montant'] = _montantController.text;
    request.fields['litre'] = _litreController.text;
    
    if (_selectedTypeCarburant != null) {
        request.fields['typeCarburant'] = _selectedTypeCarburant!;
    }

    // Ajoutez l'image si elle a été sélectionnée
      if (_image != null) {
        var pic = await http.MultipartFile.fromPath("image", _image!.path);
        request.files.add(pic);
      }
  print("Données envoyées:");
    print("Date: ${_dateController.text}");
    print("Remarque: ${_remarqueController.text}");
    print("Montant: ${_montantController.text}");
    print("Litre: ${_litreController.text}");
    print("Type de Carburant: $_selectedTypeCarburant");
    var response = await request.send();

    if (response.statusCode == 200) {
        Navigator.of(context).pop();
        String responseBody = await http.Response.fromStream(response).then((res) => res.body);
        print('Mise à jour réussie: $responseBody');
    } else {
        print('Erreur lors de la mise à jour: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de mise à jour du carburant')),
        );
    }
}

  @override
  void dispose() {
    _remarqueController.dispose();
    _dateController.dispose();
    _litreController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier Carburant')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Type de Carburant"),
                value: _selectedTypeCarburant,
                items: _typeCarburants.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTypeCarburant = newValue;
                  });
                },
              ),
              TextFormField(
                controller: _litreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Litre'),
              ),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Montant'),
              ),
              TextFormField(
                controller: _remarqueController,
                decoration: InputDecoration(labelText: 'Remarque'),
              ),
              SizedBox(height: 10),
           SizedBox(height: 10),
SizedBox(height: 10),
if (_image == null && _imageUrl == null)
  Text('Aucune image disponible.')  // Affiche ce texte si aucune image n'est présente
else if (_image != null)
  Image.file(_image!)  // Affiche l'image sélectionnée depuis la galerie
else if (_imageUrl != null)
  Image.network(_imageUrl!),  
              TextButton(
                onPressed: _pickImage,
                child: Text('Sélectionner une image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCarburant,
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
