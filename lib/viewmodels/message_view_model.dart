import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/rappel.dart';
import '../service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MessageViewModel extends ChangeNotifier {
  List<Rappel> _rappels = [];
  bool _isLoading = true;

  List<Rappel> get rappels => _rappels;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  late Rappel _rappel;
  List<dynamic> _typeEntretien = [];
  List<dynamic> _typeDepenses = [];
  
  // State variables for form
  String? _selectedTypeentretien;
  String? _selectedTypeDepense;
  String _selectedOption = 'depense'; // Initializing with 'depense'

  bool _isDateChecked = false;
  bool _isKilometrageChecked = false;

  Rappel get rappel => _rappel;
  List<dynamic> get typeEntretien => _typeEntretien;
  List<dynamic> get typeDepenses => _typeDepenses;
  String get selectedOption => _selectedOption;

  Future<void> fetchTypeEntretien() async {
    final response = await http.get(Uri.parse('${_apiService.baseUrl}/typeentretien'));
    if (response.statusCode == 200) {
      _typeEntretien = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Erreur lors du chargement des types de entretien');
    }
  }

  Future<void> fetchTypeDepenses() async {
    final response = await http.get(Uri.parse('${_apiService.baseUrl}/typedepense'));
    if (response.statusCode == 200) {
      _typeDepenses = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Erreur lors du chargement des types de dépense');
    }
  }

  Future<void> loadRappelDetails(int rappelId) async {
    final response = await http.get(Uri.parse('${_apiService.baseUrl}/rappel/$rappelId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _rappel = Rappel.fromJson(data['rappel']);
      _selectedOption = _rappel.type;
      if (_rappel.type == 'entretien') {
        _selectedTypeentretien = _rappel.typeEntretien;
        _selectedTypeDepense = null;
      } else if (_rappel.type == 'depense') {
        _selectedTypeDepense = _rappel.typeDepense;
        _selectedTypeentretien = null;
      }
      _isDateChecked = _rappel.date != null;
      _isKilometrageChecked = _rappel.kilometrage != null;
      notifyListeners();
    } else {
      throw Exception('Erreur lors du chargement des détails du rappel');
    }
  }

  Future<bool> submitForm(int rappelId, String remarque, String date, String kilometrage) async {
    var uri = Uri.parse('${_apiService.baseUrl}/updateRappel/$rappelId');
    var request = http.MultipartRequest("POST", uri);

    request.fields['remarque'] = remarque;
    request.fields['type'] = _selectedOption;

    if (_isDateChecked) request.fields['date'] = date;
    if (_isKilometrageChecked) request.fields['kilometrage'] = kilometrage;

    if (_selectedTypeentretien != null && _selectedOption == 'entretien') {
      request.fields['typeEntretien'] = _selectedTypeentretien!;
      request.fields['typeDepense'] = "";
    }

    if (_selectedTypeDepense != null && _selectedOption == 'depense') {
      request.fields['typeDepense'] = _selectedTypeDepense!;
      request.fields['typeEntretien'] = "";
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Erreur lors de l\'enregistrement');
    }
  }

  Future<void> fetchRappels() async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedVehicleId = prefs.getInt('selectedVehicleId');

    if (savedVehicleId != null) {
      try {
        final url = _apiService.baseUrl;
         final response = await http.get(Uri.parse('$url/rappels/$savedVehicleId'));
        if (response.statusCode == 200) {
          _rappels = (json.decode(response.body) as List).map((json) => Rappel.fromJson(json)).toList();
        }
      } catch (e) {
        print("Erreur : $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRappel(int id) async {
    try {
      final response = await _apiService.delete('/rappeldelete/$id');
      if (response.statusCode == 200) {
        _rappels.removeWhere((rappel) => rappel.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Erreur lors de la suppression : $e");
    }
  }
}
