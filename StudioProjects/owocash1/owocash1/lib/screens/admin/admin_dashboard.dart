import 'package:flutter/material.dart';
import 'package:owocash/screens/admin/gestion_caissiers_page.dart';
import 'package:owocash/screens/admin/liste_caisses_page.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    AdminDashboardContent(),
    ListeCaissesPage(),
    GestionCaissiersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Administrateur'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Caisses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Caissiers',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AdminDashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/liste-caisses');
                },
                icon: Icon(Icons.list),
                label: Text('Listes des caisses'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor, // Couleur de fond
                  foregroundColor: Colors.white, // Couleur du texte
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: theme.textTheme.labelLarge,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/gestion-caissiers');
                },
                icon: Icon(Icons.person),
                label: Text('Gérer les caissiers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor, // Couleur de fond
                  foregroundColor: Colors.white, // Couleur du texte
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/gestion-caisses');
            },
            icon: Icon(Icons.account_balance_wallet),
            label: Text('Gérer les caisses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor, // Couleur de fond
              foregroundColor: Colors.white, // Couleur du texte
              padding: EdgeInsets.symmetric(vertical: 16.0),
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
          Spacer(),
          Center(
            child: Image.asset(
              'assets/images/owocash_logo.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
