import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyBarChartPage extends StatefulWidget {
  @override
  _MonthlyBarChartPageState createState() => _MonthlyBarChartPageState();
}

class _MonthlyBarChartPageState extends State<MonthlyBarChartPage> {
  List<ChartData> chartData = [];

  Future<void> fetchMonthlyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');

    try {
      // Appel à l'API pour récupérer les données mensuelles
      final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/depenses-mensuelles/$vehicleId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['monthlyCosts'];
        setState(() {
          chartData = _prepareChartData(data);
        });
      } else {
        throw Exception('Erreur lors de la récupération des données');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  // Méthode pour préparer les données du graphique
  List<ChartData> _prepareChartData(dynamic data) {
    List<ChartData> chartData = [];
    data.forEach((month, totalCost) {
      chartData.add(ChartData(
        _getMonthName(int.parse(month)),  // Convertir l'index du mois en nom du mois
        totalCost.toDouble(),             // Coût total du mois
      ));
    });
    return chartData;
  }

  // Méthode pour convertir les numéros de mois en noms de mois
  String _getMonthName(int monthNumber) {
    List<String> months = [
      'Jan', 'Févr', 'Mar', 'Avr', 'Mai', 'Jui',
      'Juil', 'Aoû', 'Sept', 'Oct', 'Nov', 'Déc'
    ];
    return months[monthNumber - 1];
  }

  @override
  void initState() {
    super.initState();
    fetchMonthlyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graphique des dépenses mensuelles '),
      ),
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
              // Série pour les coûts mensuels totaux
              ColumnSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.month,
                yValueMapper: (ChartData data, _) => data.totalCost,
                name: 'Total',
                color: Colors.blue,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

// Classe de modèle pour les données du graphique
class ChartData {
  final String month;
  final double totalCost;

  ChartData(this.month, this.totalCost);
}
