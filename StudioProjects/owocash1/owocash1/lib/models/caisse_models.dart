class CaisseMere {
  final String nom;
  final List<CaisseFille> caissesFilles;
  final double soldeInitial;

  CaisseMere({
    required this.nom,
    required this.caissesFilles,
    required this.soldeInitial,
  });

  double get soldeTotal {
    return caissesFilles.fold(soldeInitial, (total, caisse) => total + caisse.soldeTotal);
  }

  factory CaisseMere.fromJson(Map<String, dynamic> json) {
    return CaisseMere(
      nom: json['nom'],
      soldeInitial: json['soldeInitial'],
      caissesFilles: (json['caissesFilles'] as List)
          .map((item) => CaisseFille.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'soldeInitial': soldeInitial,
      'caissesFilles': caissesFilles.map((caisseFille) => caisseFille.toJson()).toList(),
    };
  }
}

class CaisseFille {
  final String nom;
  final SousCaisse monetaire;
  final SousCaisse virtuelle;

  CaisseFille({
    required this.nom,
    required this.monetaire,
    required this.virtuelle,
  });

  double get soldeTotal {
    return monetaire.solde + virtuelle.solde;
  }

  factory CaisseFille.fromJson(Map<String, dynamic> json) {
    return CaisseFille(
      nom: json['nom'],
      monetaire: SousCaisse.fromJson(json['monetaire']),
      virtuelle: SousCaisse.fromJson(json['virtuelle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'monetaire': monetaire.toJson(),
      'virtuelle': virtuelle.toJson(),
    };
  }
}

class SousCaisse {
  final String type;
  double solde;

  SousCaisse({
    required this.type,
    required this.solde,
  });

  factory SousCaisse.fromJson(Map<String, dynamic> json) {
    return SousCaisse(
      type: json['type'],
      solde: json['solde'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'solde': solde,
    };
  }
}
