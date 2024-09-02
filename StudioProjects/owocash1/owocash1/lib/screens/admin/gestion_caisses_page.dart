import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:owocash/services/auth_service.dart';
import 'package:http/http.dart' as http;

class GestionCaissesPage extends StatefulWidget {
  final int? caisseMereId;

  GestionCaissesPage({this.caisseMereId});

  @override
  _GestionCaissesPageState createState() => _GestionCaissesPageState();
}

class _GestionCaissesPageState extends State<GestionCaissesPage> {
  final TextEditingController _nomCaisseController = TextEditingController();
  final TextEditingController _soldeInitialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.caisseMereId != null) {
      _fetchCaisseMereDetails();
    }
  }

  Future<void> _fetchCaisseMereDetails() async {
    try {
      final response = await AuthService.get('http://localhost:3000/caisses-mere/${widget.caisseMereId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _nomCaisseController.text = data['nom'];
        _soldeInitialController.text = data['solde_initial'].toString();
      } else {
        _handleError(response);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de connexion au serveur: $e')));
    }
  }

  Future<void> _saveCaisseMere() async {
    if (_nomCaisseController.text.isEmpty || _soldeInitialController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tous les champs doivent être remplis.')));
      return;
    }

    final caisseMereData = {
      'nom': _nomCaisseController.text,
      'solde_initial': double.tryParse(_soldeInitialController.text) ?? 0.0,
    };

    final url = widget.caisseMereId == null
        ? 'http://localhost:3000/caisses-mere'
        : 'http://localhost:3000/caisses-mere/${widget.caisseMereId}';
    final method = widget.caisseMereId == null ? AuthService.post : AuthService.put;

    try {
      final response = await method(url, body: caisseMereData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        _handleError(response);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de connexion au serveur: $e')));
    }
  }

  void _handleError(http.Response response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur ${response.statusCode}: ${response.reasonPhrase}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caisseMereId == null ? 'Ajouter une Caisse Mère' : 'Modifier la Caisse Mère'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.caisseMereId == null ? 'Nouvelle Caisse Mère' : 'Modifier Caisse Mère',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _nomCaisseController,
                    decoration: InputDecoration(
                      labelText: 'Nom de la Caisse Mère',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _soldeInitialController,
                    decoration: InputDecoration(
                      labelText: 'Solde Initial',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 30.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveCaisseMere,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                        child: Text('Enregistrer', style: TextStyle(fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
