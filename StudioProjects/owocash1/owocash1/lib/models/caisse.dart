import 'caisse_fille.dart';

class Caisse {
  final int id;
  final String nom;
  final double soldeInitial;
  final List<CaisseFille> caissesFilles;

  Caisse({
    required this.id,
    required this.nom,
    required this.soldeInitial,
    required this.caissesFilles,
  });

  double get soldeTotal {
    return soldeInitial + caissesFilles.fold(0.0, (total, caisseFille) => total + caisseFille.solde);
  }

  factory Caisse.fromJson(Map<String, dynamic> json) {
    return Caisse(
      id: json['id'],
      nom: json['nom'],
      soldeInitial: (json['solde_initial'] as num).toDouble(),
      caissesFilles: (json['caisses_filles'] as List<dynamic>)
          .map((item) => CaisseFille.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'solde_initial': soldeInitial,
      'caisses_filles': caissesFilles.map((caisseFille) => caisseFille.toJson()).toList(),
    };
  }
}
