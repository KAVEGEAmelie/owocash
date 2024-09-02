import 'package:flutter/material.dart';
import 'package:owocash/screens/admin/admin_dashboard.dart';
import 'package:owocash/screens/admin/gestion_caisses_page.dart';
import 'package:owocash/screens/admin/gestion_caissiers_page.dart';
import 'package:owocash/screens/admin/liste_caisses_page.dart';
import 'package:owocash/screens/auth/registration_page.dart';
import 'package:owocash/screens/auth/login_page.dart';
import 'package:owocash/screens/caissier/caissier_dashboard.dart';
import 'package:owocash/screens/caissier/CaissierOperationsPage.dart';
import 'package:owocash/utils/theme.dart';  

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Vérification de l'état de la base de données pour voir s'il y a des utilisateurs
  bool isDatabaseEmpty = await checkIfDatabaseIsEmpty();

  runApp(MyApp(isDatabaseEmpty: isDatabaseEmpty));
}

Future<bool> checkIfDatabaseIsEmpty() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/check-users'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      return result['isEmpty'];
    } else {
      return true; 
    }
  } catch (e) {
    // Gestion d'erreur basique
    return true;
  }
}

class MyApp extends StatelessWidget {
  final bool isDatabaseEmpty;

  MyApp({required this.isDatabaseEmpty});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OwoCash',
      theme: themeData, // Utilisez le thème personnalisé ici
      home: LoginPage(isDatabaseEmpty: isDatabaseEmpty),
      routes: {
        '/login': (context) => LoginPage(isDatabaseEmpty: true),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/gestion-caisses': (context) => GestionCaissesPage(),
        '/gestion-caissiers': (context) => GestionCaissiersPage(),
        '/liste-caisses': (context) => ListeCaissesPage(),
        '/register': (context) => RegistrationPage(),
        '/caissier-dashboard': (context) => CaissierDashboard(),
        '/caissier-operations': (context) => CaissierOperationsPage(),
      },
    );
  }
}
