import 'dart:convert';
import 'dart:io'; // Pour la gestion des fichiers locaux
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Pour sélectionner des images si nécessaire

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _imageUrl;
  String _name = '';
  String _email = '';
  File? _selectedImageFile; // Stocker le fichier local sélectionné

  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fonction pour récupérer le profil utilisateur
  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/user/$userId/profile'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _imageUrl = data['avatar']; // URL de l'image de profil
          _name = data['name'];
          _email = data['email'];
          _nameController.text = _name;
          _emailController.text = _email;
        });
      } else {
        print('Erreur lors du chargement du profil');
      }
    }
  }

  // Fonction pour mettre à jour le profil utilisateur
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId != null) {
        var uri = Uri.parse("http://192.168.1.113:8000/api/user/$userId/updateProfile");

        var request = http.MultipartRequest("POST", uri);
        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;

        if (_passwordController.text.isNotEmpty) {
          request.fields['password'] = _passwordController.text;
            print(_passwordController.text);
           print("Password !");
        }

        // Si l'utilisateur a sélectionné une nouvelle image, on l'envoie
        if (_selectedImageFile != null) {
          var pic = await http.MultipartFile.fromPath(
            "avatar",
            _selectedImageFile!.path,
          );
          request.files.add(pic);
        }

        var response = await request.send();

        if (response.statusCode == 200) {
          print("Profil mis à jour avec succès !");
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => super.widget));
        } else {
          print("Erreur lors de la mise à jour : ${response.statusCode}");
        }
      }
    }
  }

  // Fonction pour sélectionner une nouvelle image depuis la galerie
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path); // Chemin local du fichier sélectionné
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar et sélection de l'image
              GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImageFile != null
                      ? FileImage(_selectedImageFile!) // Afficher l'image locale sélectionnée
                      : (_imageUrl != null
                          ? NetworkImage(_imageUrl!) // Afficher l'image depuis le serveur
                          : AssetImage('assets/images/default_profile.png')) as ImageProvider,
                ),
              ),
              SizedBox(height: 20),
              // Champ de saisie pour le nom
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              // Champ de saisie pour l'email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre e-mail';
                  }
                  return null;
                },
              ),
              // Champ pour le mot de passe (optionnel)
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe (facultatif)'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              // Bouton pour enregistrer les modifications
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Mettre à jour le profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
