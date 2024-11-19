import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KilometrageLineChartPage extends StatefulWidget {
  @override
  _KilometrageLineChartPageState createState() =>
      _KilometrageLineChartPageState();
}

class _KilometrageLineChartPageState extends State<KilometrageLineChartPage> {
  List<ChartData> chartData = [];

  Future<void> fetchKilometrageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    if (vehicleId != null) {
      try {
        // Appel à l'API pour récupérer les données du kilométrage
        final response = await http.get(Uri.parse('$url/coupteurkilometrage/$vehicleId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            chartData = _prepareChartData(data);
          });
        } else {
          throw Exception('Erreur lors de la récupération des données');
        }
      } catch (e) {
        print('Erreur: $e');
      }
    } else {
      print('Erreur : véhicule non sélectionné.');
    }
  }

  // Méthode pour préparer les données du graphique
  List<ChartData> _prepareChartData(dynamic data) {
    List<ChartData> chartData = [];
    List<dynamic> dates = data['dates'];
    List<dynamic> kilometrages = data['kilometrages'];

    for (int i = 0; i < dates.length; i++) {
      chartData.add(ChartData(
        dates[i], // Utiliser les dates sous forme de chaînes
        kilometrages[i].toDouble(), // Valeur du kilométrage
      ));
    }

    return chartData;
  }

  @override
  void initState() {
    super.initState();
    fetchKilometrageData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Évolution du Kilométrage'),
      ),
      body: _buildLineChart(),
    );
  }

  // Construction du graphique en ligne
  Widget _buildLineChart() {
    return chartData.isNotEmpty
        ? SfCartesianChart(
            primaryXAxis: CategoryAxis(), // Utiliser un axe de catégorie pour les dates en tant que chaînes
            legend: Legend(isVisible: false),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              LineSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.date, // Date sous forme de chaîne comme X
                yValueMapper: (ChartData data, _) => data.kilometrage, // Kilométrage comme Y
                name: 'Kilométrage',
                color: Colors.blue,
                dataLabelSettings:
                    DataLabelSettings(isVisible: true), // Afficher les valeurs
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

// Classe de modèle pour les données du graphique
class ChartData {
  final String date; // Utiliser String pour les dates
  final double kilometrage;

  ChartData(this.date, this.kilometrage);
}
