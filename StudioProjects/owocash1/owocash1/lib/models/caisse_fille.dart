class CaisseFille {
  final int id;
  final String nom;
  final int caisseMereId;
  final double solde;

  CaisseFille({
    required this.id,
    required this.nom,
    required this.caisseMereId,
    required this.solde,
  });

  factory CaisseFille.fromJson(Map<String, dynamic> json) {
    return CaisseFille(
      id: json['id'],
      nom: json['nom'],
      caisseMereId: json['caisse_mere_id'],
      solde: (json['solde'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'caisse_mere_id': caisseMereId,
      'solde': solde,
    };
  }
}
