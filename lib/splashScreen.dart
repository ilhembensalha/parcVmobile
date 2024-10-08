import 'package:carhabty/auth_screens.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Méthode pour naviguer vers la page d'accueil après un délai
  void _navigateToHome() {
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()), // Remplacez HomePage par votre page principale
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ajoutez votre logo ici
            Image.asset(
              'assets/icon/app_icon.png', // Assurez-vous d'avoir une image de logo dans le dossier assets
              height: 150,
            ),
            SizedBox(height: 20),
            SizedBox(height: 10),
          //  CircularProgressIndicator(), // Indicateur de chargement
          ],
        ),
      ),
    );
  }
}

// Exemple de page d'accueil
