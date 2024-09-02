import 'package:flutter/material.dart';

class CaissierDashboard extends StatefulWidget {
  @override
  _CaissierDashboardState createState() => _CaissierDashboardState();
}

class _CaissierDashboardState extends State<CaissierDashboard> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _soldePrecedentController = TextEditingController();
  final TextEditingController _fondCaisseController = TextEditingController();

  int _nombreBillets = 0;
  int _nombrePieces = 0;
  bool _billetageEffectue = false;

  void _openBilletageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BilletageDialog(
          onBilletageComplete: (billets, pieces) {
            setState(() {
              _nombreBillets = billets;
              _nombrePieces = pieces;
              _billetageEffectue = true;
            });
          },
        );
      },
    );
  }

  void _submitCaisse() {
    double soldePrecedent = double.tryParse(_soldePrecedentController.text) ?? 0.0;
    double fondCaisse = double.tryParse(_fondCaisseController.text) ?? 0.0;

    // Calcul du total du billetage
    double billetsTotal = _nombreBillets * 10000.0; // Exemples : billets de 10000 XAF
    double piecesTotal = _nombrePieces * 1000.0; // Exemples : pièces de 1000 XAF
    double totalBilletage = billetsTotal + piecesTotal;

    // Calcul de l'écart
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
              Text('Total Billets: ${billetsTotal.toStringAsFixed(2)} XAF'),
              Text('Total Pièces: ${piecesTotal.toStringAsFixed(2)} XAF'),
              Text('Écart: ${ecart.toStringAsFixed(2)} XAF'),
              Text('Commentaire: $commentaire'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Logique pour ouvrir la caisse après confirmation
              },
              child: Text('Ouvrir la Caisse'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Caissier'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logique pour la déconnexion
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ouverture de Caisse',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _soldePrecedentController,
                decoration: InputDecoration(
                  labelText: 'Solde Précédent',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _openBilletageDialog,
                child: Text('Billetage'),
              ),
              SizedBox(height: 16.0),
              if (_billetageEffectue) // Affiche la section uniquement si le billetage est effectué
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Résumé du Billetage', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8.0),
                      Text('Nombre de Billets: $_nombreBillets'),
                      Text('Nombre de Pièces: $_nombrePieces'),
                    ],
                  ),
                ),
              SizedBox(height: 16.0),
              TextField(
                controller: _fondCaisseController,
                decoration: InputDecoration(
                  labelText: 'Fond de Caisse',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitCaisse,
                child: Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Options',
          ),
        ],
        onTap: (index) {
          // Logique pour gérer les appuis sur les éléments de la barre de navigation
        },
      ),
    );
  }
}

class BilletageDialog extends StatefulWidget {
  final Function(int, int) onBilletageComplete;

  BilletageDialog({required this.onBilletageComplete});

  @override
  _BilletageDialogState createState() => _BilletageDialogState();
}

class _BilletageDialogState extends State<BilletageDialog> {
  final TextEditingController _billetsController = TextEditingController();
  final TextEditingController _piecesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Billetage'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _billetsController,
            decoration: InputDecoration(
              labelText: 'Nombre de Billets',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.money),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _piecesController,
            decoration: InputDecoration(
              labelText: 'Nombre de Pièces',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            int billets = int.tryParse(_billetsController.text) ?? 0;
            int pieces = int.tryParse(_piecesController.text) ?? 0;
            widget.onBilletageComplete(billets, pieces);
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
