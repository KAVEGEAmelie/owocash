import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:owocash/screens/admin/admin_dashboard.dart';
import 'package:owocash/screens/auth/ResetPasswordPage.dart';
import 'package:owocash/screens/caissier/caissier_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  bool isDatabaseEmpty;

  LoginPage({required this.isDatabaseEmpty});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _emailController = TextEditingController(); 

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchProtectedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      _showError('Token non trouvé. Veuillez vous reconnecter.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/protected-route'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Données reçues : $data');
      } else {
        String errorMessage =
            'Erreur lors de la récupération des données : ${response.statusCode}';
        if (response.statusCode == 401) {
          errorMessage = 'Token invalide ou expiré. Veuillez vous reconnecter.';
        }
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Erreur de connexion : $e');
    }
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _usernameController.text.toString(),
          'password': _passwordController.text.toString(),
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['accessToken'];
        final String role = data['role'];

        // Stocker le token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', token);

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else if (role == 'caissier') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CaissierDashboard()),
          );
        } else {
          _showError('Rôle utilisateur inconnu');
        }
      } else {
        _showError('Nom d\'utilisateur ou mot de passe incorrect');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur de connexion : $e');
    }
  }

  Future<bool> _checkIfDatabaseIsEmpty() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/check-users'));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        print('Parsed Result: $result'); // Debug
        return result['isEmpty'] ?? true;
      } else {
        print('Failed to get response: ${response.statusCode}');
        return true;
      }
    } catch (e) {
      print('Error checking database: $e');
      return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

Future<void> _sendResetLink() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/reset-password'), // Remplacez par l'URL de votre serveur
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text.toString(),
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lien de réinitialisation envoyé !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de connexion : $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FutureBuilder<bool>(
            future: _checkIfDatabaseIsEmpty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Erreur : ${snapshot.error}');
              }

              bool isDatabaseEmpty = snapshot.data ?? true;
              print('Is Database Empty: $isDatabaseEmpty'); // Debug

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Owo Cash',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Nom d\'utilisateur',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: 'Mot de passe',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _login(context),
                    icon: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Icon(Icons.arrow_forward),
                    label: Text(
                        _isLoading ? 'Connexion en cours...' : 'Se connecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isDatabaseEmpty)
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/register');
                            },
                      icon: Icon(Icons.person_add),
                      label: Text('Configurer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
    );
  },
  child: Text(
    'Mot de passe oublié ?',
    style: TextStyle(color: Colors.white),
  ),
),

                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
