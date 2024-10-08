import 'package:carhabty/models/Depense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailDepensePage extends StatelessWidget {
  final Depense depense;

  DetailDepensePage({required this.depense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails de la Dépense')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Afficher la date de la dépense
            ListTile(
              title: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(depense.date, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher le type de dépense
            ListTile(
              title: Text('Type de dépense', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(depense.typeDepense.toString(), style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher la remarque
            ListTile(
              title: Text('Remarque', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(depense.remarque, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher le montant
            ListTile(
              title: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(depense.montant.toString() + ' €', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Afficher l'image si elle existe
            depense.image != null
                ? Image.network(depense.image!)
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
