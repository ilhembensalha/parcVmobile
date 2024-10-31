import 'dart:io';
import 'package:carhabty/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditRappelPage extends StatefulWidget {
  final int rappelId; // ID du rappel à modifier

  EditRappelPage({required this.rappelId});

  @override
  _EditRappelPageState createState() => _EditRappelPageState();
}

class _EditRappelPageState extends State<EditRappelPage> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _typeEntretien = [];
  List<dynamic> _typeDepenses = [];
  String? _selectedTypeentretien;
  String? _selectedTypeDepense;

  String _selectedOption = 'Dépense'; // Pour stocker le type sélectionné (Dépense ou Entretien)

  bool _isDateChecked = false;
  bool _isKilometrageChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchTypeEntretien();
    _fetchTypeDepenses();
    _loadRappelDetails(); // Charge les détails de l'événement de rappel
  }

  Future<void> _fetchTypeEntretien() async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/typeentretien'));

    if (response.statusCode == 200) {
      setState(() {
        _typeEntretien = json.decode(response.body);
      });
    } else {
      throw Exception('Erreur lors du chargement des types de entretien');
    }
  }

  Future<void> _fetchTypeDepenses() async {
    final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/typedepense'));

    if (response.statusCode == 200) {
      setState(() {
        _typeDepenses = json.decode(response.body);
      });
    } else {
      throw Exception('Erreur lors du chargement des types de dépense');
    }
  }


Future<void> _loadRappelDetails() async {
  final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/rappel/${widget.rappelId}'));
  print(widget.rappelId);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);

    // Accéder à l'objet 'rappel' dans la réponse
    final rappel = data['rappel'];
    print(rappel);

    setState(() {
      // Vérifiez que les données sont disponibles avant de les attribuer aux contrôleurs et variables
      _remarqueController.text = rappel['remarque'] ?? ''; 
      _dateController.text = rappel['date'] ?? ''; 
      _kilometrageController.text = rappel['kilometrage'] != null ? rappel['kilometrage'].toString() : ''; 
      
      // Déterminez si le type est "Entretien" ou "Dépense" et mettez à jour la sélection
      _selectedOption = rappel['type'] ;
      
      if (_selectedOption == 'entretien') {
        _selectedTypeentretien = rappel['typeEntretien']?.toString();
        _selectedTypeDepense = null; // Réinitialise typeDepense si non applicable
      } else if (_selectedOption == 'depense') {
        _selectedTypeDepense = rappel['typeDepense']?.toString();
        _selectedTypeentretien = null; // Réinitialise typeEntretien si non applicable
      }
        print(_selectedOption);
          print(rappel['typeDepense']);
            print(rappel['typeEntretien']);
      print(_selectedTypeentretien);
      print(_selectedTypeDepense);

      // Met à jour les valeurs des checkboxes en fonction des données reçues
      _isDateChecked = rappel['date'] != null;
      _isKilometrageChecked = rappel['kilometrage'] != null;
    });
  } else {
    throw Exception('Erreur lors du chargement des détails du rappel');
  }
}

  // Form field controllers
  TextEditingController _dateController = TextEditingController();
  TextEditingController _remarqueController = TextEditingController();
  TextEditingController _kilometrageController = TextEditingController();
  DateTime? _selectedDate;

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
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var uri = Uri.parse("http://192.168.1.113:8000/api/updateRappel/${widget.rappelId}");
      var request = http.MultipartRequest("POST", uri);

      request.fields['remarque'] = _remarqueController.text;
      request.fields['type'] = _selectedOption;
      print(_selectedOption);
      print(_selectedTypeentretien);

      if (_isDateChecked) {
        request.fields['date'] = _dateController.text;
      }
      if (_isKilometrageChecked) {
        request.fields['kilometrage'] = _kilometrageController.text;
      }

      if (_selectedTypeentretien != null && _selectedOption == 'entretien') {
        request.fields['typeEntretien'] = _selectedTypeentretien!;
         request.fields['typeDepense'] = "";
      }
      if (_selectedTypeDepense != null && _selectedOption == 'depense') {
        request.fields['typeDepense'] = _selectedTypeDepense!;
        request.fields['typeEntretien'] = "";
      }

  

      var response = await request.send();
      if (response.statusCode == 200) {
         Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Rappel modifié avec succès !"),
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
        title: Text('Modifier Rappel'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOption = 'depense';
                      });
                    },
                    child: Text('Dépense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == 'depense' ? Colors.blue : Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOption = 'entretien';
                      });
                    },
                    child: Text('Entretien'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == 'entretien' ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_selectedOption == 'depense')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Type de Dépense'),
                  value: _selectedTypeDepense,
                  items: _typeDepenses.map<DropdownMenuItem<String>>((dynamic type) {
                    return DropdownMenuItem<String>(
                      value: type['id'].toString(),
                      child: Text(type['name']),
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
              if (_selectedOption == 'entretien')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Type de Entretien'),
                  value: _selectedTypeentretien,
                  items: _typeEntretien.map<DropdownMenuItem<String>>((dynamic type) {
                    return DropdownMenuItem<String>(
                      value: type['id'].toString(),
                      child: Text(type['name']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTypeentretien = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un type d\'entretien';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _remarqueController,
                decoration: InputDecoration(labelText: 'Remarque'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _kilometrageController,
                decoration: InputDecoration(labelText: 'Kilométrage'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
