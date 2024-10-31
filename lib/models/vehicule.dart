import 'package:carhabty/models/Carburant.dart';
import 'package:carhabty/models/Depense.dart';
import 'package:carhabty/models/Entretien.dart';

class Vehicule {
   int id;
   String nomV;
   String marque;
   String modele;
   String type;
   String status;
   String immatriculation;
   String? vin;
   String? kilometrage;
   String datePc;
   List<Entretien> fuel;
   List<Depense> expenses;
   List<Carburant> maintenance;

  Vehicule({
    required this.id,
    required this.nomV,
    required this.marque,
    required this.modele,
    required this.type,
    required this.status,
    required this.immatriculation,
    this.vin,
    this.kilometrage,
    required this.datePc,
    required this.fuel,
    required this.expenses,
    required this.maintenance,
  });

  Map<String, dynamic> toJson() {
    return {
     'nomV': nomV,
    'marque': marque,
    'modele': modele,
    'type': type,
    'immatriculation': immatriculation,
    'kilometrage': kilometrage,
    'datePc': datePc,
    };
  }
  factory Vehicule.fromJson(Map<String, dynamic> json) {
    return Vehicule(
      id: json['id'] ?? 0,
      nomV: json['nomV'] ?? 'Nom inconnu',
      marque: json['marque'] ?? 'Marque inconnue',
      modele: json['modele'] ?? 'Modèle inconnu',
      type: json['type'] ?? 'Type inconnu',
      status: json['status'] ?? 'Statut inconnu',
      immatriculation: json['immatriculation'] ?? 'Immatriculation inconnue',
      vin: json['vin'],
      kilometrage: json['kilometrage']?.toString(),
      datePc: json['datePc'] ?? 'Date inconnue',
      fuel: (json['fuel'] as List?)?.map((i) => Entretien.fromJson(i)).toList() ?? [],
      expenses: (json['expenses'] as List?)?.map((i) => Depense.fromJson(i)).toList() ?? [],
      maintenance: (json['maintenance'] as List?)?.map((i) => Carburant.fromJson(i)).toList() ?? [],
    );
  }
}