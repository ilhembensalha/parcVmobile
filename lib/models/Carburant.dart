class Carburant {
  final int id;
  final dynamic remarque;
  final dynamic date;
  final dynamic litre;
  final dynamic montant;
  final dynamic typeCarburant;
  final dynamic vehicule;
  final dynamic image;
  final dynamic conducteur;

  Carburant({
    required this.id,
    required this.remarque,
    required this.date,
    required this.litre,
    required this.montant,
    required this.typeCarburant,
    required this.vehicule,
    required this.image,
    required this.conducteur,
  });

  factory Carburant.fromJson(Map<String, dynamic> json) {
    return Carburant(
      id: json['id'],
      remarque: json['remarque'] ?? 'Remarque inconnue', // Valeur par défaut si remarque est null
      date: json['date'] ?? 'Date inconnue', // Valeur par défaut si date est null
      litre: json['litre'] ?? 0, // Par défaut 0 litre si non fourni
      montant: json['montant'] ?? 0, // Par défaut 0 montant si non fourni
      typeCarburant: json['TypeCarburant'] ?? 'Type inconnu', // Valeur par défaut si null
      vehicule: json['vehicule'] ?? 'Véhicule inconnu', // Valeur par défaut si null
      image: json['image'] ?? null, // Valeur par défaut si null
      conducteur: json['conducteur'] ?? 'Conducteur inconnu', // Valeur par défaut si null
    );
  }
}
