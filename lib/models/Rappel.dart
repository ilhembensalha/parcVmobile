class Rappel {
  final int id;
  final dynamic remarque;
  final dynamic date;
  final dynamic type;
  final dynamic vehicule;
  final dynamic conducteur;
  final dynamic kilometrage;
  final dynamic typeDepense;
  final dynamic typeEntretien;

 
    

  Rappel({
    required this.id,
    required this.remarque,
    required this.date,
    required this.type,
    required this.typeDepense,
    required this.typeEntretien,
   required this.vehicule,
    required this.kilometrage,
    required this.conducteur,
  });

  factory Rappel.fromJson(Map<String, dynamic> json) {
    return Rappel(
      id: json['id'],
      remarque: json['remarque'] ?? 'Remarque inconnue', // Valeur par défaut si remarque est null
      date: json['date'] ?? 'Date inconnue', // Valeur par défaut si date est null
      kilometrage: json['kilometrage'] ?? 0, // Par défaut 0 litre si non fourni
      type: json['type'] ?? 'Type inconnu', // Valeur par défaut si null
      vehicule: json['vehicule'] ?? 'Véhicule inconnu', // Valeur par défaut si null
        typeDepense: json['typeDepense'] ?? 'Type de dépense inconnu',
       typeEntretien: json['typeEntretien'] ?? 'Type entretien inconnu', // Valeur par défaut si le type est null
      conducteur: json['conducteur'] ?? 'Conducteur inconnu', // Valeur par défaut si null
    );
  }
}
