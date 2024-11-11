import 'dart:convert';
import 'dart:io';

import 'package:carhabty/models/Depense.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditDepensePage extends StatefulWidget {
  final Depense depense;

  EditDepensePage({required this.depense});

  @override
  _EditDepensePageState createState() => _EditDepensePageState();
}

class _EditDepensePageState extends State<EditDepensePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController _montantController = TextEditingController();
  TextEditingController _remarqueController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
   String? _imageUrl;

  List<dynamic> _typeDepenses = [];
  String? _selectedTypeDepense;
  File? _image;
  DateTime? _selectedDate;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _montantController.text = widget.depense.montant.toString();
    _remarqueController.text = widget.depense.remarque;
    _dateController.text = widget.depense.date;
    _imageUrl = widget.depense.image; 
    _fetchTypeDepenses();
  }

  Future<void> _fetchTypeDepenses() async {
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    final response = await http.get(Uri.parse('$url/typedepense'));

    if (response.statusCode == 200) {
      setState(() {
        _typeDepenses = json.decode(response.body);
        _selectedTypeDepense = widget.depense.typeDepense.toString(); // Préréglage de typeDepense
      });
    } else {
      throw Exception('Erreur lors du chargement des types de dépense');
    }
  }

  // Select date function
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

  // Pick image function
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Save changes
  Future<void> _saveDepense() async {
      final ApiService _apiService = ApiService();
      final urll= _apiService.baseUrl;
      print(urll);
    String url = '$urll/expenses/${widget.depense.id}';

    var request = http.MultipartRequest("POST", Uri.parse(url));

    request.fields['date'] = _dateController.text;
    request.fields['remarque'] = _remarqueController.text;
    request.fields['montant'] = _montantController.text;


    if (_selectedTypeDepense != null) {
      request.fields['typeDepense'] = _selectedTypeDepense!;
    }

    if (_image != null) {
      var pic = await http.MultipartFile.fromPath("image", _image!.path);
      request.files.add(pic);
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Dépense mise à jour avec succès');
      Navigator.of(context).pop();
    } else {
      throw Exception('Erreur lors de la mise à jour');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier Dépense')),
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
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la date';
                  }
                  return null;
                },
                readOnly: true,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type de dépense'),
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
                _image == null && _imageUrl != null
                  ? Image.network(_imageUrl!)
                  : _image != null
                      ? Image.file(_image!)
                      : Text('Aucune image sélectionnée.'),

              TextButton(
                onPressed: _pickImage,
                child: Text('Sélectionner une image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDepense,
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
