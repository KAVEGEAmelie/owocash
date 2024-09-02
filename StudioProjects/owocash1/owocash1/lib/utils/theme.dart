import 'package:flutter/material.dart';

final ThemeData themeData = ThemeData(
  primarySwatch: Colors.blue,
  hintColor: Colors.grey, // Couleur du texte d'indice
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor:  Colors.blue, // Définir la couleur de fond des pages
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color.fromARGB(255, 146, 207, 234), // Couleur de fond des champs de texte
    hintStyle: TextStyle(color: Colors.grey), // Style du texte d'indice
    labelStyle: TextStyle(color: Colors.black), // Style du texte de label
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Bord arrondi pour les champs de texte
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue), // Couleur de la bordure lorsque le champ est activé
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent), // Couleur de la bordure lorsque le champ est focalisé
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: Colors.black, fontSize: 32), // Style pour displayLarge
    displayMedium: TextStyle(color: Colors.black, fontSize: 28), // Style pour displayMedium
    displaySmall: TextStyle(color: Colors.black, fontSize: 24), // Style pour displaySmall
    headlineMedium: TextStyle(color: Colors.black, fontSize: 20), // Style pour headlineMedium
    headlineSmall: TextStyle(color: Colors.black, fontSize: 18), // Style pour headlineSmall
    titleLarge: TextStyle(color: Colors.black, fontSize: 16), // Style pour titleLarge
    bodyLarge: TextStyle(color: Colors.black, fontSize: 14), // Style pour bodyLarge
    bodyMedium: TextStyle(color: Colors.black, fontSize: 12), // Style pour bodyMedium
    bodySmall: TextStyle(color: Colors.black, fontSize: 10), // Style pour bodySmall
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue, // Couleur de fond des boutons
    textTheme: ButtonTextTheme.primary, // Couleur du texte des boutons
  ),
);
