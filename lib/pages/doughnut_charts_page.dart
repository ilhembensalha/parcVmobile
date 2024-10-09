import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les réponses JSON
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutChartsPage extends StatefulWidget {
  DoughnutChartsPage({Key? key}) : super(key: key);

  @override
  _DoughnutChartsPageState createState() => _DoughnutChartsPageState();
}

class _DoughnutChartsPageState extends State<DoughnutChartsPage> {
  double? coutTotal;
  double? coutmaint;
  double? coutdepense;
  double? coutfuel;

  Future<void> fetchCoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
    try {
      final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/rapportcout/$vehicleId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          coutTotal = data['coutTotal']?.toDouble();
          coutmaint = data['totalEntretien']?.toDouble();
          coutdepense = data['totalDepense']?.toDouble();
          coutfuel = data['totalCarburant']?.toDouble();
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
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Graphiques à Anneau'),
    ),
    body: SingleChildScrollView( // Permet de faire défiler si le contenu dépasse la taille de l'écran
      child: _buildDoughnutCharts(),
    ),
  );
}

Widget _buildDoughnutCharts() {
  // Protéger contre la division par zéro et les valeurs nulles
  double maintenancePercentage = (coutmaint != null && coutTotal != 0) ? (coutmaint! / coutTotal!) * 100 : 0;
  double expensesPercentage = (coutdepense != null && coutTotal != 0) ? (coutdepense! / coutTotal!) * 100 : 0;
  double fuelPercentage = (coutfuel != null && coutTotal != 0) ? (coutfuel! / coutTotal!) * 100 : 0;

  // Créer la liste des données pour chaque catégorie
  List<ChartData> maintenanceData = [
    ChartData('Entretien', maintenancePercentage),
    ChartData('Restant', 100 - maintenancePercentage),
  ];

  List<ChartData> expensesData = [
    ChartData('Dépenses', expensesPercentage),
    ChartData('Restant', 100 - expensesPercentage),
  ];

  List<ChartData> fuelData = [
    ChartData('Carburant', fuelPercentage),
    ChartData('Restant', 100 - fuelPercentage),
  ];

  return Container(
    padding: EdgeInsets.all(8), // Ajout d'un peu d'espace autour
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildChartWithLabel(maintenanceData, 'Entretien', maintenancePercentage, Colors.red),
            _buildChartWithLabel(expensesData, 'Dépenses', expensesPercentage, Colors.blue),
            _buildChartWithLabel(fuelData, 'Carburant', fuelPercentage, Colors.yellow),
          ],
        ),
      ],
    ),
  );
}

Widget _buildChartWithLabel(List<ChartData> data, String label, double percentage, Color color) {
  return Flexible( // Utilisation de Flexible pour s'adapter à l'espace
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100, // Hauteur réduite pour le graphique
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                pointColorMapper: (ChartData data, _) {
                  return data.category == label ? color : Colors.transparent;
                },
                dataLabelMapper: (ChartData data, _) => '${data.category} ${data.value.toStringAsFixed(1)}%',
                dataLabelSettings: DataLabelSettings(isVisible: false),
              ),
            ],
          ),
        ),
        SizedBox(height: 4), // Espacement entre le graphique et le texte
        Text(
          '$label: ${percentage.toStringAsFixed(1)}%', 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // Taille de police réduite
          textAlign: TextAlign.center, // Centrer le texte
        ),
      ],
    ),
  );
}
}

class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}
