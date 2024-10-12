import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyCarburantChart extends StatefulWidget {
  @override
  _MonthlyCarburantChartState createState() => _MonthlyCarburantChartState();
}

class _MonthlyCarburantChartState extends State<MonthlyCarburantChart> {
  List<ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    fetchMonthlyCarburantData();
  }

  Future<void> fetchMonthlyCarburantData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');

    try {
      final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/graphcoutcarburant/$vehicleId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          chartData = _prepareChartData(data['monthlycarburant']);
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
      // Récupérez le mois et le coût associé
      int month = int.parse(key);
      double cost = value.toDouble(); // Assurez-vous que les données sont de type double
      chartData.add(ChartData(_getMonthLabel(month), cost)); // Ajouter les données
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
      appBar: AppBar(title: Text('Graphique des Coûts de Carburant Mensuels')),
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
                yValueMapper: (ChartData data, _) => data.cost,
                name: 'Coûts',
                color: Colors.blue,
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
  final double cost;

  ChartData(this.month, this.cost);
}
