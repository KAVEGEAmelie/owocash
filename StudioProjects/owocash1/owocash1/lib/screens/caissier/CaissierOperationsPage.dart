import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:owocash/models/caisse.dart'; 
import 'package:owocash/models/caisse_models.dart'; 

class CaissierOperationsPage extends StatefulWidget {
  @override
  _CaissierOperationsPageState createState() => _CaissierOperationsPageState();
}

class _CaissierOperationsPageState extends State<CaissierOperationsPage> {
  List<Caisse> _caisses = [];

  @override
  void initState() {
    super.initState();
    _fetchCaisses();
  }

  void _fetchCaisses() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/caisses'), 
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _caisses = data.map((json) => Caisse.fromJson(json)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des caisses')),
      );
    }
  }

  void _updateCaisse(Caisse caisse) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/update-caisse'), 
      headers: {'Content-Type': 'application/json'},
      body: json.encode(caisse.toJson()),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Caisse mise à jour')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour de la caisse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opérations Caissier'),
      ),
      body: ListView.builder(
        itemCount: _caisses.length,
        itemBuilder: (context, index) {
          final caisse = _caisses[index];
          return ListTile(
            title: Text(caisse.nom),
            subtitle: Text('Solde: ${caisse.soldeTotal} XOF'), 
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _updateCaisse(caisse);
              },
            ),
          );
        },
      ),
    );
  }
}
