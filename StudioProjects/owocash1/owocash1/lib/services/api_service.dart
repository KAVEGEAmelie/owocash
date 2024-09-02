import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owocash/models/user.dart';
import 'package:owocash/models/caisse_models.dart';

class ApiService {
  final String apiUrl = "http://localhost:3000";  

  // Utilisateur
  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$apiUrl/users'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => User.fromJson(data)).toList();
    } else {
      throw Exception('Échec du chargement des utilisateurs');
    }
  }

  Future<http.Response> addUser(User user) async {
    final response = await http.post(
      Uri.parse('$apiUrl/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    return response;
  }

  Future<http.Response> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$apiUrl/users/${user.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }

  // Caisse Mère
  Future<List<CaisseMere>> getCaissesMeres() async {
    final response = await http.get(Uri.parse('$apiUrl/caisses-mere'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => CaisseMere.fromJson(data)).toList();
    } else {
      throw Exception('Échec du chargement des caisses mères');
    }
  }

  Future<http.Response> addCaisseMere(CaisseMere caisseMere) async {
    final response = await http.post(
      Uri.parse('$apiUrl/caisses-mere'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(caisseMere.toJson()),
    );
    return response;
  }

  Future<http.Response> updateCaisseMere(CaisseMere caisseMere) async {
    final response = await http.put(
      Uri.parse('$apiUrl/caisses-mere/${caisseMere.nom}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(caisseMere.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteCaisseMere(String nom) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/caisses-mere/$nom'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }

  // Caisse Fille
  Future<List<CaisseFille>> getCaissesFilles(String caisseMereNom) async {
    final response = await http.get(Uri.parse('$apiUrl/caisses-mere/$caisseMereNom/caisses-filles'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => CaisseFille.fromJson(data)).toList();
    } else {
      throw Exception('Échec du chargement des caisses filles');
    }
  }

  Future<http.Response> addCaisseFille(String caisseMereNom, CaisseFille caisseFille) async {
    final response = await http.post(
      Uri.parse('$apiUrl/caisses-mere/$caisseMereNom/caisses-filles'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(caisseFille.toJson()),
    );
    return response;
  }

  Future<http.Response> updateCaisseFille(String caisseMereNom, CaisseFille caisseFille) async {
    final response = await http.put(
      Uri.parse('$apiUrl/caisses-mere/$caisseMereNom/caisses-filles/${caisseFille.nom}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(caisseFille.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteCaisseFille(String caisseMereNom, String nom) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/caisses-mere/$caisseMereNom/caisses-filles/$nom'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }
}
