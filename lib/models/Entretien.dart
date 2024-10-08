class Entretien {
  final int id;
  final dynamic date;
  final dynamic remarque;
  final dynamic typeEntretien;
  final dynamic vehicule;
  final dynamic image;
  final dynamic conducteur;
  final dynamic montant;

  Entretien({
    required this.id,
    required this.date,
    required this.remarque,
    required this.typeEntretien,
    required this.vehicule,
    required this.image,
    required this.conducteur,
    required this.montant,
  });

  factory Entretien.fromJson(Map<String, dynamic> json) {
    return Entretien(
      id: json['id'],
      date: json['date'] ?? 'Date inconnue', // Valeur par défaut si la date est null
      remarque: json['remarque'] ?? 'Remarque inconnue', // Valeur par défaut si la remarque est null
      typeEntretien: json['typeEntretien'] ?? 'Type entretien inconnu', // Valeur par défaut si le type est null
      vehicule: json['vehicule'] ?? 'Véhicule inconnu', // Valeur par défaut si le véhicule est null
      image: json['image'] ?? null, // Valeur par défaut si l'image est null
      conducteur: json['conducteur'] ?? 'Conducteur inconnu', // Valeur par défaut si le conducteur est null
      montant: json['montant'] ?? 0, // Valeur par défaut à 0 si montant non fourni
    );
  }
}
