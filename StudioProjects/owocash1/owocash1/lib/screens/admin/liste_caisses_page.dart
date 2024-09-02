import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:owocash/models/caisse_mere.dart';
import 'package:owocash/models/caisse_fille.dart';
import 'gestion_caisses_page.dart';

class ListeCaissesPage extends StatelessWidget {
  Future<List<CaisseMere>> fetchCaissesMere() async {
    final response = await http.get(Uri.parse('http://localhost:3000/caisses-mere'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => CaisseMere.fromJson(item)).toList();
    } else {
      throw Exception('Erreur de chargement des caisses mères : ${response.statusCode}');
    }
  }

  Future<List<CaisseFille>> fetchCaissesFilles(int caisseMereId) async {
    final response = await http.get(Uri.parse('http://localhost:3000/caisses-filles?caisseMereId=$caisseMereId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => CaisseFille.fromJson(item)).toList();
    } else {
      throw Exception('Erreur de chargement des caisses filles : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Caisses Mères'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des Caisses Mères',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<CaisseMere>>(
                future: fetchCaissesMere(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucune caisse mère trouvée'));
                  } else {
                    final caissesMere = snapshot.data!;
                    return ListView.builder(
                      itemCount: caissesMere.length,
                      itemBuilder: (context, index) {
                        final caisseMere = caissesMere[index];
                        return ExpansionTile(
                          title: Text(caisseMere.nom),
                          subtitle: Text('Solde Initial: ${caisseMere.soldeInitial}'),
                          children: [
                            FutureBuilder<List<CaisseFille>>(
                              future: fetchCaissesFilles(caisseMere.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Erreur: ${snapshot.error}'));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Center(child: Text('Aucune caisse fille trouvée'));
                                } else {
                                  final caissesFilles = snapshot.data!;
                                  return Column(
                                    children: caissesFilles.map((caisseFille) {
                                      return ListTile(
                                        title: Text(caisseFille.nom),
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GestionCaissesPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
