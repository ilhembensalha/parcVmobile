import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceCostPieChart extends StatefulWidget {
  @override
  _MaintenanceCostPieChartState createState() => _MaintenanceCostPieChartState();
}

class _MaintenanceCostPieChartState extends State<MaintenanceCostPieChart> {
  List<ChartData> chartData = [];

  Future<void> fetchMaintenanceCostData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');

    if (vehicleId != null) {
      try {
        // Appel à l'API pour récupérer les données des coûts d'entretien par type
        final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/entretienGraphepartype/$vehicleId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            chartData = _prepareChartData(data['costsByType']);
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

  // Préparer les données pour le graphique
  List<ChartData> _prepareChartData(Map<String, dynamic> data) {
    List<ChartData> chartData = [];

    data.forEach((type, cost) {
      chartData.add(ChartData(type, cost.toDouble()));
    });

    return chartData;
  }

  @override
  void initState() {
    super.initState();
    fetchMaintenanceCostData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coûts total des Entretiens par Type'),
      ),
      body: _buildPieChart(),
    );
  }

  // Construction du graphique en camembert
  Widget _buildPieChart() {
    return chartData.isNotEmpty
        ? SfCircularChart(
            legend: Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <PieSeries<ChartData, String>>[
              PieSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.type,
                yValueMapper: (ChartData data, _) => data.cost,
                dataLabelSettings: DataLabelSettings(isVisible: true), // Affiche les étiquettes avec les valeurs
              )
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

// Classe de modèle pour les données du graphique
class ChartData {
  final String type;
  final double cost;

  ChartData(this.type, this.cost);
}
