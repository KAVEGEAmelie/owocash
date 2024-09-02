class CaisseFille {
  final int id;
  final String nom;
  final String nomCaisseMere;
  final double solde;

  CaisseFille({
    required this.id,
    required this.nom,
    required this.nomCaisseMere,
    required this.solde,
  });

  factory CaisseFille.fromJson(Map<String, dynamic> json) {
    return CaisseFille(
      id: json['id'],
      nom: json['nom'],
      nomCaisseMere: json['nom_caisse_mere'],
      solde: (json['solde'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'nom_caisse_mere': nomCaisseMere,
      'solde': solde,
    };
  }
}
