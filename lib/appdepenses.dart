import 'dart:io';
import 'package:carhabty/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; 
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
    List<dynamic> _typeDepenses = [];
  String? _selectedTypeDepense;
@override
  void initState() {
    super.initState();
    _loadVehicle(); 
    _fetchTypeDepenses(); // Charge les données de véhicule depuis le local storage
  }

  Future<void> _fetchTypeDepenses() async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/typedepense'));

    if (response.statusCode == 200) {
      setState(() {
        _typeDepenses = json.decode(response.body); // Décode la réponse JSON
      });
    } else {
      throw Exception('Erreur lors du chargement des types de dépense');
    }
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
 bool _obscureText = true;
  // Variable pour stocker la date sélectionnée
  DateTime? _selectedDate;

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
      var uri = Uri.parse("http://192.168.1.113:8000/api/store");

      var request = http.MultipartRequest("POST", uri);

      request.fields['date'] = _dateController.text;
      request.fields['remarque'] = _remarqueController.text;
      request.fields['montant'] = _montantController.text;
      request.fields['vehicule'] = _vehiculeController.text;
      request.fields['conducteur'] = _conducteurController.text;
       if (_selectedTypeDepense != null) {
      request.fields['typeDepense'] = _selectedTypeDepense!; // ID du type de dépense
    }


      // Attach the image if selected
      if (_image != null) {
        var pic = await http.MultipartFile.fromPath("image", _image!.path);
        request.files.add(pic);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        print("Dépense ajoutée avec succès !");
          Navigator.push(
        context, new MaterialPageRoute(builder: (context) => Spincircle()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Dépense ajoutée avec succès !"),
    ));
      } else {
        print("Erreur : ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Dépense'),
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
                decoration: InputDecoration(labelText: 'Type de dépense'),
                value: _selectedTypeDepense,
                items: _typeDepenses.map<DropdownMenuItem<String>>((dynamic type) {
                  return DropdownMenuItem<String>(
                    value: type['id'].toString(), // Utilise l'ID comme valeur
                    child: Text(type['name']), // Affiche le nom du type de dépense
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTypeDepense = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un type de dépense';
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
