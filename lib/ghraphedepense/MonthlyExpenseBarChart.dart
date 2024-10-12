import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyExpenseBarChart extends StatefulWidget {
  @override
  _MonthlyExpenseBarChartState createState() => _MonthlyExpenseBarChartState();
}

class _MonthlyExpenseBarChartState extends State<MonthlyExpenseBarChart> {
  List<ChartData> chartData = [];

  Future<void> fetchMonthlyExpenseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');

    if (vehicleId != null) {
      try {
        // Appel à l'API pour récupérer les données des dépenses mensuelles
        final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/depenseGrapheMen/$vehicleId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            chartData = _prepareChartData(data['monthlyCosts']);
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

    // Mapper les données sur les mois
    for (int i = 1; i <= 12; i++) {
      double expense = data[i.toString()]?.toDouble() ?? 0.0; // Obtenir la valeur du mois
      chartData.add(ChartData(_getMonthLabel(i), expense)); // Ajouter la donnée
    }

    return chartData;
  }

  // Méthode pour obtenir le nom du mois
  String _getMonthLabel(int month) {
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    fetchMonthlyExpenseData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dépenses Mensuelles'),
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
              ColumnSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.month,
                yValueMapper: (ChartData data, _) => data.expense,
                name: 'Dépenses',
                color: Colors.blue,
                dataLabelSettings: DataLabelSettings(isVisible: true), // Affiche les valeurs sur les barres
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

// Classe de modèle pour les données du graphique
class ChartData {
  final String month;
  final double expense;

  ChartData(this.month, this.expense);
}
