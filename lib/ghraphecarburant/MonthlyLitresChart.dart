import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyLitresChart extends StatefulWidget {
  @override
  _MonthlyLitresChartState createState() => _MonthlyLitresChartState();
}

class _MonthlyLitresChartState extends State<MonthlyLitresChart> {
  List<ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    fetchMonthlyLitresData();
  }

  Future<void> fetchMonthlyLitresData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');

    try {
      final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/graphlitre/$vehicleId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          chartData = _prepareChartData(data['monthlylitre']);
        });
      } else {
        throw Exception('Erreur lors de la récupération des données');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  // Préparez les données pour le graphique
  List<ChartData> _prepareChartData(Map<String, dynamic> data) {
    List<ChartData> chartData = [];

    data.forEach((key, value) {
      int month = int.parse(key);
      double litres = value.toDouble();
      chartData.add(ChartData(_getMonthLabel(month), litres)); // Ajouter les données
    });

    return chartData;
  }

  // Méthode pour obtenir le nom du mois
  String _getMonthLabel(int month) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Graphique des Consommations de Litres Mensuels')),
      body: _buildBarChart(),
    );
  }

  // Construction du graphique en barres
  Widget _buildBarChart() {
    return chartData.isNotEmpty
        ? SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            legend: Legend(isVisible: false),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              ColumnSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.month,
                yValueMapper: (ChartData data, _) => data.litres,
                name: 'Litres',
                color: Colors.green,
                dataLabelSettings: DataLabelSettings(isVisible: true), // Affiche les valeurs sur les barres
              ),
            ],
          )
        : Center(child: CircularProgressIndicator()); // Indicateur de chargement
  }
}

// Classe de modèle pour les données du graphique
class ChartData {
  final String month;
  final double litres;

  ChartData(this.month, this.litres);
}
