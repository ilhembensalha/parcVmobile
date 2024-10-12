import 'package:carhabty/pagesRapports/entretienrapport.dart';
import 'package:carhabty/pagesRapports/carburantRapport.dart';
import 'package:carhabty/pagesRapports/Generale.dart';
import 'package:carhabty/pagesRapports/depenserapport.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Add extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            // TabBar without AppBar
            PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: Container(
     // You can style the background
                child: TabBar(
                  indicatorColor: Color.fromARGB(255, 4, 33, 90),
                  labelColor:Color.fromARGB(255, 4, 33, 90),
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(text: 'Generale'),
                    Tab( text: 'Depense'),
                    Tab( text: 'Entretien'),
                    Tab( text: 'Carburant'),
                  ],
                ),
              ),
            ),
            // TabBarView for displaying pagess
            Expanded(
              child: TabBarView(
                children: [
                  Generale(),
                   depense(),
                  Entretien(),   
                  carburant(),            
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}