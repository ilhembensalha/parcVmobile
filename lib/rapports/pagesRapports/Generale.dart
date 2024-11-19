import 'package:carhabty/graphiquegenerale/KilometrageLineChartPage.dart';
import 'package:carhabty/graphiquegenerale/MonthlyBarChartPage.dart';
import 'package:carhabty/graphiquegenerale/barcharts.dart';
import 'package:carhabty/graphiquegenerale/doughnut_charts_page.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les réponses JSON
import 'package:shared_preferences/shared_preferences.dart';

class Generale extends StatefulWidget {
  @override
  _GeneraleState createState() => _GeneraleState();
}

class _GeneraleState extends State<Generale> {
  // Variables pour stocker les coûts récupérés
  var coutTotal;
  var coutmois;
  var coutAnnee;
  var sumKilometrageThisMonth;
  var sumKilometrageThisYear;
  var distance;
  var coutmaint;
  var coutdepense;
  var coutfuel;
    String? selectedOption;

  // Liste des options à afficher dans la liste déroulante
  final List<String> options = ['Répartition des Coûts Ce Mois', 'Répartition des Coûts total', 'Graphique des dépenses mensuelles','kilometrage'];

  // Méthode pour appeler l'API
  Future<void> fetchCoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    try {
      final response = await http.get(Uri.parse('$url/rapportcout/$vehicleId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          coutTotal = data['coutTotal'];
          coutmois = data['coutTotalMois'];
          coutAnnee = data['coutTotalAnnee'];
          coutmaint = data['totalEntretien'];
          coutdepense= data['totalDepense'];
          coutfuel= data['totalCarburant'];
        });
      } else {
        throw Exception('Erreur lors de la récupération des données');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  Future<void> fetchDistanseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
      final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    try {
      final response = await http.get(Uri.parse('$url/rapportdistanse/$vehicleId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          distance = data['distance'];
          sumKilometrageThisYear = data['sumKilometrageThisYear'];
          sumKilometrageThisMonth = data['sumKilometrageThisMonth'];
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
    fetchDistanseData();
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
                  Text('Distance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDistanceColumn('Total ', distance),
                      _buildDistanceColumn('Ce Mois ', sumKilometrageThisMonth),
                      _buildDistanceColumn('Cette Année ', sumKilometrageThisYear),
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
                if (newValue == 'Répartition des Coûts total') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoughnutChartsPage()),
                  );
                }
                 if (newValue == 'Répartition des Coûts Ce Mois') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BarChartPage()),
                  );
                }
                 if (newValue == 'Graphique des dépenses mensuelles') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MonthlyBarChartPage()),
                  );
                }
                if (newValue == 'kilometrage') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => KilometrageLineChartPage()),
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

  Column _buildDistanceColumn(String label, var value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text('${value ?? 0} KM', style: TextStyle(fontSize: 18)),
      ],
    );
  }

}