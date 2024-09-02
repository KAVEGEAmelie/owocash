import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owocash/models/caissier.dart';

class GestionCaissiersPage extends StatefulWidget {
  @override
  _GestionCaissiersPageState createState() => _GestionCaissiersPageState();
}

class _GestionCaissiersPageState extends State<GestionCaissiersPage> {
  List<Caissier> utilisateurs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUtilisateurs();
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jsonwebtoken', token);
    print('Token stocké : $token');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    print('Token récupéré : $token');
    return token;
  }

Future<void> _fetchUtilisateurs() async {
  setState(() {
    _isLoading = true;
  });

  final token = await _getToken();
  if (token == null) {
    _showError('Token d\'authentification non trouvé');
    setState(() {
      _isLoading = false;
    });
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        utilisateurs = jsonResponse.map((data) => Caissier.fromJson(data)).toList();
      });
    } else {
      _showError('Erreur lors de la récupération des utilisateurs : ${response.statusCode}');
    }
  } catch (e) {
    _showError('Exception lors de la récupération : $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

// // Future<void> _fetchUtilisateurs() async {
//   setState(() {
//     _isLoading = true;
//   });

//   const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzI0ODg1NTg2LCJleHAiOjE3MjQ4ODkxODZ9.fEqXPGgfx-WX6-hUOLmuSmvIFrypNlvF23KDj55kVWE'; // Remplacez par un token valide

//   try {
//     final response = await http.get(
//       Uri.parse('http://localhost:3000/users'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = json.decode(response.body);
//       setState(() {
//         utilisateurs = jsonResponse.map((data) => Caissier.fromJson(data)).toList();
//       });
//     } else {
//       _showError('Erreur lors de la récupération des utilisateurs : ${response.statusCode}');
//     }
//   } catch (e) {
//     _showError('Exception lors de la récupération : $e');
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }


  Future<void> _addUtilisateur(String username, String role, String password) async {
    final token = await _getToken();
    if (token == null) {
      _showError('Token d\'authentification non trouvé');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'username': username, 'password': password, 'role': role}),
      );

      if (response.statusCode == 201) {
        _fetchUtilisateurs();
      } else {
        _showError('Erreur lors de l\'ajout de l\'utilisateur : ${response.body}');
      }
    } catch (e) {
      _showError('Exception lors de l\'ajout : $e');
    }
  }

  Future<void> _updateUtilisateur(String id, String username, String role, [String? password]) async {
    final token = await _getToken();
    if (token == null) {
      _showError('Token d\'authentification non trouvé');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'role': role,
          if (password != null && password.isNotEmpty) 'password': password,
        }),
      );

      if (response.statusCode == 200) {
        _fetchUtilisateurs();
      } else {
        _showError('Erreur lors de la mise à jour de l\'utilisateur : ${response.body}');
      }
    } catch (e) {
      _showError('Exception lors de la mise à jour : $e');
    }
  }

  Future<void> _deleteUtilisateur(String id) async {
    final token = await _getToken();
    if (token == null) {
      _showError('Token d\'authentification non trouvé');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/users/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        _fetchUtilisateurs();
      } else {
        _showError('Erreur lors de la suppression de l\'utilisateur : ${response.statusCode}');
      }
    } catch (e) {
      _showError('Exception lors de la suppression : $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Utilisateurs')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: utilisateurs.length,
              itemBuilder: (context, index) {
                final utilisateur = utilisateurs[index];
                return ListTile(
                  title: Text(utilisateur.username),
                  subtitle: Text(utilisateur.role),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUtilisateurDialog(utilisateur: utilisateur),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteUtilisateur(utilisateur.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUtilisateurDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showUtilisateurDialog({Caissier? utilisateur}) {
    String username = utilisateur?.username ?? '';
    String password = '';
    String role = utilisateur?.role ?? 'caissier';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(utilisateur == null ? 'Ajouter un Utilisateur' : 'Modifier l\'Utilisateur'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: username,
                  onChanged: (value) => username = value,
                  decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                ),
                if (utilisateur == null)
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) => password = value,
                    decoration: InputDecoration(labelText: 'Mot de passe'),
                  ),
                DropdownButtonFormField<String>(
                  value: role,
                  onChanged: (value) {
                    if (value != null) role = value;
                  },
                  items: ['admin', 'caissier']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Rôle'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (utilisateur == null) {
                  _addUtilisateur(username, role, password);
                } else {
                  _updateUtilisateur(utilisateur.id, username, role, password);
                }
                Navigator.of(context).pop();
              },
              child: Text(utilisateur == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }
}
