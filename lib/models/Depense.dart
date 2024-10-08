class Depense {
  final int id;
  final dynamic montant; // Utilisez dynamic si le type peut varier
  final dynamic date;
  final dynamic remarque;
  final dynamic typeDepense;
  final dynamic vehicule;
  final dynamic image;
  final dynamic conducteur;

  Depense({
    required this.id,
    required this.montant,
    required this.date,
    required this.remarque,
    required this.typeDepense,
    required this.vehicule,
    required this.image,
    required this.conducteur,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      montant: json['montant'], // dynamic acceptera à la fois String et int
      date: json['date'] ?? 'Date inconnue',
      remarque: json['remarque'] ?? 'Remarque inconnue',
      typeDepense: json['typeDepense'] ?? 'Type de dépense inconnu',
      vehicule: json['vehicule'] ?? 'Véhicule inconnu',
      image: json['image'] ?? null,
      conducteur: json['conducteur'] ?? 'Conducteur inconnu',
    );
  }
}
