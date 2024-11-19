import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BarChartPage extends StatefulWidget {
  @override
  _BarChartPageState createState() => _BarChartPageState();
}

class _BarChartPageState extends State<BarChartPage> {
  double? coutFuel;
  double? coutEntretien;
  double? coutDepense;

  Future<void> fetchCoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');
final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    try {
      final response = await http.get(Uri.parse('$url/rapportbarchartsmois/$vehicleId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          coutFuel = data['totalmoiscarbirant']?.toDouble();
          coutEntretien = data['totalmoisentretien']?.toDouble();
          coutDepense = data['totalmoisdepense']?.toDouble();
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
        title: Text('Répartition des Coûts Ce Mois'),
      ),
      body: _buildBarChart(),
    );
  }

  Widget _buildBarChart() {
    return coutFuel != null && coutEntretien != null && coutDepense != null
        ? SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            legend: Legend(isVisible: false),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              BarSeries<ChartData, String>(
                dataSource: [
                  ChartData('Carburant', coutFuel!),
                  ChartData('Entretien', coutEntretien!),
                  ChartData('Dépenses', coutDepense!),
                ],
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                name: 'Coûts',
                color: Colors.blue,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}
