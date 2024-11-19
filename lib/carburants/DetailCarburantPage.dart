import 'package:carhabty/models/Carburant.dart';
import 'package:flutter/material.dart';

class DetailCarburantPage extends StatelessWidget {
  final Carburant carburant;

  DetailCarburantPage({required this.carburant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails Carburant')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Affichage de la date
            ListTile(
              title: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(carburant.date, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Affichage du type de carburant
            ListTile(
              title: Text('Type de Carburant', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(carburant.typeCarburant ?? 'Non spécifié', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Affichage du litre
            ListTile(
              title: Text('Litre', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(carburant.litre.toString() + ' L', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Affichage du montant
            ListTile(
              title: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(carburant.montant.toString() + ' €', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Affichage de la remarque
            ListTile(
              title: Text('Remarque', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(carburant.remarque.isNotEmpty ? carburant.remarque : 'Aucune remarque', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),

            // Affichage de l'image si elle existe
            carburant.image != null
                ? Image.network(carburant.image!)
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
