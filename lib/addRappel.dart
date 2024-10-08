import 'dart:io';
import 'package:carhabty/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddrappelPage extends StatefulWidget {
  @override
  _AddrappelPageState createState() => _AddrappelPageState();
}

class _AddrappelPageState extends State<AddrappelPage> {
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
    _loadVehicle();
    _fetchTypeEntretien();
    _fetchTypeDepenses(); // Charge les types disponibles
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

  Future<void> _loadVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
    if (vehicleId != null) {
      _vehiculeController.text = vehicleId.toString();
    }
    int? userId = prefs.getInt('userId');
    if (userId != null) {
      _conducteurController.text = userId.toString();
    }
  }

  // Form field controllers
  TextEditingController _dateController = TextEditingController();
  TextEditingController _remarqueController = TextEditingController();
  TextEditingController _vehiculeController = TextEditingController();
  TextEditingController _conducteurController = TextEditingController();
  TextEditingController _kilometrageController = TextEditingController();
  bool _obscureText = true;
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

  File? _image;
  final picker = ImagePicker();

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var uri = Uri.parse("http://192.168.1.113:8000/api/storeRappel");
      var request = http.MultipartRequest("POST", uri);


      request.fields['remarque'] = _remarqueController.text;
      request.fields['vehicule'] = _vehiculeController.text;
     
      request.fields['conducteur'] = _conducteurController.text;
      request.fields['type'] = _selectedOption;

        if (_isDateChecked) {
        request.fields['date'] = _dateController.text;
      }
      if (_isKilometrageChecked) {
        request.fields['kilometrage'] = _kilometrageController.text;
      }

      if (_selectedTypeentretien != null && _selectedOption == 'Entretien') {
        request.fields['typeEntretien'] = _selectedTypeentretien!;
      }
      if (_selectedTypeDepense != null && _selectedOption == 'Dépense') {
        request.fields['typeDepense'] = _selectedTypeDepense!;
      }

      if (_image != null) {
        var pic = await http.MultipartFile.fromPath("image", _image!.path);
        request.files.add(pic);
      }

      var response = await request.send();
      if (response.statusCode == 201) {
          Navigator.push(
        context, new MaterialPageRoute(builder: (context) => Spincircle()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Rappel ajouté avec succès !"),
    ));
        print("Rappel ajouté avec succès !");
      } else {
        print("Erreur : ${response.statusCode}");
      }
    }
  }
    // Fonction pour vérifier si un champ est rempli et afficher la case à cocher correspondante
  void _updateCheckboxVisibility() {
    setState(() {
      _isDateChecked = _dateController.text.isNotEmpty;
      _isKilometrageChecked = _kilometrageController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Rappel'),
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
                        _selectedOption = 'Dépense';
                      });
                    },
                    child: Text('Dépense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == 'Dépense' ? Colors.blue : Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOption = 'Entretien';
                      });
                    },
                    child: Text('Entretien'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == 'Entretien' ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Affiche le champ de type selon la sélection
              if (_selectedOption == 'Dépense')
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
              if (_selectedOption == 'Entretien')
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
                      return 'Veuillez sélectionner un type de entretien';
                    }
                    return null;
                  },
                ),
           TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (_isDateChecked && (value == null || value.isEmpty)) {
                    return 'Veuillez entrer la date';
                  }
                  return null;
                },
                onChanged: (value) {
                  _updateCheckboxVisibility();
                },
                readOnly: true,
              ),
              // Affiche la case à cocher si la date est remplie
              if (_dateController.text.isNotEmpty)
                Row(
                  children: [
                    Text("Envoyer la date"),
                    Checkbox(
                      value: _isDateChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isDateChecked = value!;
                        });
                      },
                    ),
                  ],
                ),

              // Champ Kilométrage avec case à cocher (affiche si le kilométrage est rempli)
              TextFormField(
                controller: _kilometrageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Kilométrage'),
                validator: (value) {
                  if (_isKilometrageChecked && (value == null || value.isEmpty)) {
                    return 'Veuillez entrer le kilométrage';
                  }
                  return null;
                },
                onChanged: (value) {
                  _updateCheckboxVisibility();
                },
              ),
              // Affiche la case à cocher si le kilométrage est rempli
              if (_kilometrageController.text.isNotEmpty)
                Row(
                  children: [
                    Text("Envoyer le kilométrage"),
                    Checkbox(
                      value: _isKilometrageChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isKilometrageChecked = value!;
                        });
                      },
                    ),
                  ],
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
