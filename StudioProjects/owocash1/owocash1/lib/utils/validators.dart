// validators.dart

// Exemple de fonction de validation pour un email
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez entrer un email';
  }
  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email invalide';
  }
  return null;
}

// Exemple de fonction de validation pour un mot de passe
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez entrer un mot de passe';
  }
  if (value.length < 6) {
    return 'Le mot de passe doit comporter au moins 6 caractères';
  }
  return null;
}
