import 'dart:io';
import 'package:carhabty/home.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; 
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddCarburantPage extends StatefulWidget {
  @override
  _AddCarburantPageState createState() => _AddCarburantPageState();
}

class _AddCarburantPageState extends State<AddCarburantPage> {
  final _formKey = GlobalKey<FormState>();

@override
  void initState() {
    super.initState();
    _loadVehicle(); 
   // Charge les données de véhicule depuis le local storage
  }


  // Fonction pour charger le véhicule depuis le local storage
 Future<void> _loadVehicle() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? vehicleId = prefs.getInt('selectedVehicleId'); // Récupère l'ID du véhicule en tant qu'entier

  if (vehicleId != null) {
    _vehiculeController.text = vehicleId.toString(); // Convertit l'int en String pour le contrôleur
  }
    int? userId = prefs.getInt('userId'); // Récupère l'ID du véhicule en tant qu'entier

  if (vehicleId != null) {
    _conducteurController.text = userId.toString(); // Convertit l'int en String pour le contrôleur
  }

}
  // Form field controllers
  TextEditingController _dateController = TextEditingController();
  TextEditingController _remarqueController = TextEditingController();
  TextEditingController _montantController = TextEditingController();
  TextEditingController _vehiculeController = TextEditingController();
  TextEditingController _conducteurController = TextEditingController();
   TextEditingController _litreController = TextEditingController();
  // Variable pour stocker la date sélectionnée
  DateTime? _selectedDate;
   final List<String> _typeCarburants = ["Essence", "Diesel","Essence premium","Ethanol","Essence Moyenne"];
  String? _selectedTypeCarburant;

  // Fonction pour afficher le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!); // Formater la date
      });
    }
  }

  File? _image;
  final picker = ImagePicker();

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Function to send the form data to Laravel API
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
        final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
      var uri = Uri.parse("$url/storeCarburant");

      var request = http.MultipartRequest("POST", uri);

      request.fields['date'] = _dateController.text;
      request.fields['remarque'] = _remarqueController.text;
      request.fields['montant'] = _montantController.text;
      request.fields['vehicule'] = _vehiculeController.text;
      request.fields['conducteur'] = _conducteurController.text;
      request.fields['litre'] = _litreController.text;
         // Envoyer le type de carburant sélectionné
      if (_selectedTypeCarburant != null) {
        request.fields['TypeCarburant'] = _selectedTypeCarburant!; // ID ou nom du type de carburant
      }

      // Attach the image if selected
      if (_image != null) {
        var pic = await http.MultipartFile.fromPath("image", _image!.path);
        request.files.add(pic);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
          Navigator.push(
        context, new MaterialPageRoute(builder: (context) => Spincircle()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Carburant ajoutée avec succès "),
    ));
        print("Carburant ajoutée avec succès !");
      } else {
        print("Erreur : ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Carburant'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
             TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context), // Ouvrir le sélecteur de date
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la date';
                  }
                  return null;
                },
                readOnly: true, // Empêche l'utilisateur de taper directement
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
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un type de carburant';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _remarqueController,
                decoration: InputDecoration(labelText: 'Remarque'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une remarque';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Montant'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le montant';
                  }
                  return null;
                },
              ),
               TextFormField(
                controller: _litreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'litre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le litre';
                  }
                  return null;
                },
              ),
             
              SizedBox(height: 10),
              _image == null
                  ? Text('Aucune image sélectionnée.')
                  : Image.file(_image!),
              TextButton(
                onPressed: _pickImage,
                child: Text('Sélectionner une image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
