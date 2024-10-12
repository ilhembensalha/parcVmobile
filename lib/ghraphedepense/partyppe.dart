import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DepenseCostPieChart extends StatefulWidget {
  @override
  _DepenseCostPieChartState createState() => _DepenseCostPieChartState();
}

class _DepenseCostPieChartState extends State<DepenseCostPieChart> {
  List<ChartData> chartData = [];
  bool isLoading = true; // Variable pour suivre le statut du chargement

  Future<void> fetchDepenseCostData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? vehicleId = prefs.getInt('selectedVehicleId');

    if (vehicleId != null) {
      try {
        // Appel à l'API pour récupérer les données des coûts de dépense par type
        final response = await http.get(Uri.parse('http://192.168.1.113:8000/api/depenseGraphepartype/$vehicleId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            chartData = _prepareChartData(data);
            isLoading = false; // Fin du chargement
          });
        } else {
          setState(() {
            isLoading = false; // Fin du chargement même en cas d'erreur
          });
          throw Exception('Erreur lors de la récupération des données');
        }
      } catch (e) {
        setState(() {
          isLoading = false; // Fin du chargement en cas d'erreur
        });
        // Afficher une erreur
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  // Méthode pour préparer les données du graphique
  List<ChartData> _prepareChartData(dynamic data) {
    List<ChartData> chartData = [];
    data['costsByType'].forEach((type, total) {
      chartData.add(ChartData(type, total.toDouble()));
    });
    return chartData;
  }

  @override
  void initState() {
    super.initState();
    fetchDepenseCostData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coûts total des Dépenses par Type'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement pendant la récupération des données
          : chartData.isNotEmpty
              ? _buildPieChart() // Si les données existent, afficher le graphique
              : Center(child: Text('Pas de données disponibles')), // Si pas de données, afficher ce message
    );
  }

  // Construction du graphique en secteurs
  Widget _buildPieChart() {
    return SfCircularChart(
      legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.type, // Type de dépense comme X
          yValueMapper: (ChartData data, _) => data.total, // Total comme Y
          dataLabelSettings: DataLabelSettings(isVisible: true), // Afficher les valeurs sur les secteurs
          explode: true, // Séparer les sections
          explodeIndex: 0, // Séparer la première section
        ),
      ],
    );
  }
}

// Classe de modèle pour les données du graphique
class ChartData {
  final String type;
  final double total;

  ChartData(this.type, this.total);
}
