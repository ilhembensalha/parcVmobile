import 'dart:convert';
import 'dart:io';
import 'package:carhabty/home.dart';
import 'package:carhabty/models/Entretien.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditEntretienPage extends StatefulWidget {
  final Entretien entretien;

  EditEntretienPage({required this.entretien});

  @override
  _EditEntretienPageState createState() => _EditEntretienPageState();
}

class _EditEntretienPageState extends State<EditEntretienPage> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> _typeEntretien = [];
  String? _selectedTypeentretien;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _remarqueController = TextEditingController();
  TextEditingController _montantController = TextEditingController();

     String? _imageUrl;

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _remarqueController.text = widget.entretien.remarque;
    _dateController.text = widget.entretien.date;
    _montantController.text = widget.entretien.montant.toString();
    _selectedTypeentretien = widget.entretien.typeEntretien.toString(); // Récupère le type d'entretien
     _imageUrl = widget.entretien.image; 
    _fetchTypeEntretien();
  }

  Future<void> _fetchTypeEntretien() async {
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    final response = await http.get(Uri.parse('$url/typeentretien'));

    if (response.statusCode == 200) {
      setState(() {
        _typeEntretien = json.decode(response.body);
      });
    } else {
      throw Exception('Erreur lors du chargement des types d\'entretien');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
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

  Future<void> _submitForm() async {
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    if (_formKey.currentState!.validate()) {
      var uri = Uri.parse("$url/maintenance/${widget.entretien.id}");

      var request = http.MultipartRequest("POST", uri);
      request.fields['date'] = _dateController.text;
      request.fields['remarque'] = _remarqueController.text;
      request.fields['montant'] = _montantController.text;
      if (_selectedTypeentretien != null) {
        request.fields['typeEntretien'] = _selectedTypeentretien!;
      }

      if (_image != null) {
        var pic = await http.MultipartFile.fromPath("image", _image!.path);
        request.files.add(pic);
      }
   print(request);
   print("Données envoyées:");
    print("Date: ${_dateController.text}");
    print("Remarque: ${_remarqueController.text}");
    print("Montant: ${_montantController.text}");

      var response = await request.send();
      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Spincircle()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Entretien mis à jour avec succès !")));
      } else {
     
        print("Erreur : ${response.statusCode}");
          print("Erreur : ${response.request}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier Entretien')),
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
                onPressed: _submitForm,
                child: Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
