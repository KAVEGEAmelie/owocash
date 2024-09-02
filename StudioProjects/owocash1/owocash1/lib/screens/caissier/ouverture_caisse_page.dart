import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:owocash/screens/caissier/CaissierOperationsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OuvertureCaissePage extends StatefulWidget {
  @override
  _OuvertureCaissePageState createState() => _OuvertureCaissePageState();
}

class _OuvertureCaissePageState extends State<OuvertureCaissePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _soldePrecedentController = TextEditingController();
  final TextEditingController _fondCaisseController = TextEditingController();
  final TextEditingController _nombreBilletsController = TextEditingController();
  final TextEditingController _nombrePiecesController = TextEditingController();

  double _billetsTotal = 0.0;
  double _piecesTotal = 0.0;

  void _calculBilletage() {
    setState(() {
      int billets = int.tryParse(_nombreBilletsController.text) ?? 0;
      int pieces = int.tryParse(_nombrePiecesController.text) ?? 0;

      _billetsTotal = billets * 10000.0;
      _piecesTotal = pieces * 1000.0;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Efface toutes les préférences sauvegardées

    Navigator.pushReplacementNamed(context, '/login'); // Redirige vers la page de connexion
  }

  void _submitCaisse() {
    if (_dateController.text.isEmpty || 
        _soldePrecedentController.text.isEmpty ||
        _fondCaisseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    double soldePrecedent = double.tryParse(_soldePrecedentController.text) ?? 0.0;
    double fondCaisse = double.tryParse(_fondCaisseController.text) ?? 0.0;
    double totalBilletage = _billetsTotal + _piecesTotal;

    double ecart = fondCaisse - (soldePrecedent + totalBilletage);
    String commentaire;

    if (ecart == 0) {
      commentaire = "Tout est en ordre. Aucun écart détecté.";
    } else if (ecart > 0) {
      commentaire = "Le fond de caisse dépasse le solde attendu de ${ecart.toStringAsFixed(2)} XAF.";
    } else {
      commentaire = "Il manque ${(-ecart).toStringAsFixed(2)} XAF dans le fond de caisse.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reçu de Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${_dateController.text}'),
              Text('Solde Précédent: ${_soldePrecedentController.text} XAF'),
              Text('Fond de Caisse: ${_fondCaisseController.text} XAF'),
              Text('Total Billets: ${_billetsTotal.toStringAsFixed(2)} XAF'),
              Text('Total Pièces: ${_piecesTotal.toStringAsFixed(2)} XAF'),
              Text('Écart: ${ecart.toStringAsFixed(2)} XAF'),
              Text('Commentaire: $commentaire'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialog
                _openCaisse();  // Appel de la méthode pour ouvrir la caisse
              },
              child: Text('Ouvrir la Caisse'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialog
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _openCaisse() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/ouverture-caisse'), // Assurez-vous que cette URL est correcte
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': _dateController.text,
        'soldePrecedent': double.tryParse(_soldePrecedentController.text) ?? 0.0,
        'fondCaisse': double.tryParse(_fondCaisseController.text) ?? 0.0,
        'totalBillets': _billetsTotal,
        'totalPieces': _piecesTotal,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CaissierOperationsPage(), // Rediriger vers la page des opérations du caissier
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ouverture de la caisse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ouverture de Caisse'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Appelle la méthode de déconnexion
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _soldePrecedentController,
              decoration: InputDecoration(
                labelText: 'Solde Précédent',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _fondCaisseController,
              decoration: InputDecoration(
                labelText: 'Fond de Caisse',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nombreBilletsController,
              decoration: InputDecoration(
                labelText: 'Nombre de Billets',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nombrePiecesController,
              decoration: InputDecoration(
                labelText: 'Nombre de Pièces',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculBilletage,
              child: Text('Calculer Billetage'),
            ),
            SizedBox(height: 16),
            if (_billetsTotal > 0 || _piecesTotal > 0)
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Billets: ${_billetsTotal.toStringAsFixed(2)} XAF', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Total Pièces: ${_piecesTotal.toStringAsFixed(2)} XAF', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitCaisse,
              child: Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}
