import 'package:carhabty/pages/BikePage.dart';
import 'package:carhabty/pages/CarPage.dart';
import 'package:carhabty/pages/Generale.dart';
import 'package:carhabty/pages/TransitPage.dart';
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
                    Tab(text: 'GENERALE'),
                    Tab( text: 'Transit'),
                    Tab( text: 'Bike'),
                    Tab( text: 'Bike'),
                  ],
                ),
              ),
            ),
            // TabBarView for displaying pages
            Expanded(
              child: TabBarView(
                children: [
                  Generale(),
                  CarPage(),        // First tab's page
                  TransitPage(),    // Second tab's page
                  BikePage(),      // Third tab's page
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}