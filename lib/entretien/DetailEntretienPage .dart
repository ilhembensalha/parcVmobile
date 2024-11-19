import 'dart:io';
import 'package:carhabty/models/Entretien.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailEntretienPage extends StatelessWidget {
  final Entretien entretien;

  DetailEntretienPage({required this.entretien});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails Entretien')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Afficher la date de l'entretien
            ListTile(
              title: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(entretien.date, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher le type d'entretien
            ListTile(
              title: Text('Type d\'entretien', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(entretien.typeEntretien.toString(), style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher la remarque
            ListTile(
              title: Text('Remarque', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(entretien.remarque, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher le montant
            ListTile(
              title: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(entretien.montant.toString() + ' €', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher l'image si elle existe
            entretien.image != null
                ? Image.network(entretien.image!)
                : Text('Aucune image disponible.'),

            SizedBox(height: 20),

            // Bouton retour
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
