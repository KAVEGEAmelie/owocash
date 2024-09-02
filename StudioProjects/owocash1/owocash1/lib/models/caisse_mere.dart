class CaisseMere {
  final int id;
  final String nom;
  final double soldeInitial;

  CaisseMere({
    required this.id,
    required this.nom,
    required this.soldeInitial,
  });

  factory CaisseMere.fromJson(Map<String, dynamic> json) {
    return CaisseMere(
      id: json['id'],
      nom: json['nom'],
      soldeInitial: (json['solde_initial'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'solde_initial': soldeInitial,
    };
  }
}
