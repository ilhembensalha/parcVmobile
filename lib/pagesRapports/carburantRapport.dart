import 'package:carhabty/ghraphecarburant/MonthlyCarburantChart.dart';
import 'package:carhabty/ghraphecarburant/MonthlyLitresChart.dart';
import 'package:carhabty/graphiqueCharts/doughnut_charts_page.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les réponses JSON
import 'package:shared_preferences/shared_preferences.dart';

class carburant extends StatefulWidget {
  @override
  _carburantState createState() => _carburantState();
}

class _carburantState extends State<carburant> {
  // Variables pour stocker les coûts récupérés
  var coutTotal;
  var coutmois;
  var coutAnnee;
  var litre ;
  var litremonth ;
  var litreyear;

    String? selectedOption;

  // Liste des options à afficher dans la liste déroulante
  final List<String> options = ['Graphique des Coûts de Carburant Mensuels', 'Graphique des Consommations Carburant  Mensuels'];

  // Méthode pour appeler l'API
  Future<void> fetchCoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
    try {
      final response = await http.get(Uri.parse('http://192.168.1.17:8000/api/rapportCarburant/$vehicleId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          coutTotal = data['totalDepense'];
          coutmois = data['coutTotalMois'];
          coutAnnee = data['coutTotalAnnee'];
        });
      } else {
        throw Exception('Erreur lors de la récupération des données');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  Future<void> fetchLitreData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    try {
      final response = await http.get(Uri.parse('$url/consomation/$vehicleId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          litre = data['litretotel'];
          litreyear = data['carburantlitretmonth'];
          litremonth = data['carburantlitreyear'];
        });
      } else {
        throw Exception('Erreur lors de la récupération des données');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCoutData();
    fetchLitreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: coutTotal == null || coutmois == null || coutAnnee == null
            ? Center(child: CircularProgressIndicator()) // Indicateur de chargement
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coûts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCostColumn('Total', coutTotal),
                      _buildCostColumn('Ce Mois', coutmois),
                      _buildCostColumn('Cette Année', coutAnnee),
                    ],
                  ),
                     SizedBox(height: 40),
                  Text('Consomation en L ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLitreColumn('Total ', litre),
                      _buildLitreColumn('Ce Mois ', litremonth),
                      _buildLitreColumn('Cette Année ', litreyear),
                    ],
                  ),
                  SizedBox(height: 40),
                 
                     Text('Graphiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 
                  SizedBox(height: 20),
            Row(
  children: [
    Expanded(
      child: Row(
        children: [
          Icon(Icons.assessment), // Icône ajoutée ici
          SizedBox(width: 8), // Espacement entre l'icône et le DropdownButton
          Expanded( // Assurez-vous que le DropdownButton est dans un Expanded
            child: DropdownButton<String>(
              value: selectedOption,
              hint: Text('Sélectionnez une option'),
              isExpanded: true, // S'assure que le DropdownButton prend toute la largeur
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue;
                });
                // Naviguer vers une autre page si 'Répartition des Coûts total' est sélectionné
                if (newValue == 'Graphique des Coûts de Carburant Mensuels') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MonthlyCarburantChart()),
                  );
                }
                 if (newValue == 'Graphique des Consommations Carburant  Mensuels') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MonthlyLitresChart()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ),
  ],
),

                
                ],
              ),
      ),
    );
  }

  Column _buildCostColumn(String label, var value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text('${value ?? 0} DT', style: TextStyle(fontSize: 18)),
      ],
    );
  }

  Column _buildLitreColumn(String label, var value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text('${value ?? 0} L', style: TextStyle(fontSize: 18)),
      ],
    );
  }

}