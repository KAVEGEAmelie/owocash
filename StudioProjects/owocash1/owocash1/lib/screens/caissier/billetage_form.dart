import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BilletageForm extends StatefulWidget {
  @override
  _BilletageFormState createState() => _BilletageFormState();
}

class _BilletageFormState extends State<BilletageForm> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _previousBalanceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _coinsController = TextEditingController();
  final TextEditingController _initialFundController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date: ${DateFormat.yMd().format(selectedDate)}'),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text('Sélectionner la date'),
          ),
          TextField(
            controller: _previousBalanceController,
            decoration: InputDecoration(labelText: 'Solde précédent'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: 'Billets'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _coinsController,
            decoration: InputDecoration(labelText: 'Pièces'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _initialFundController,
            decoration: InputDecoration(labelText: 'Fonds initial'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Logique de soumission du formulaire
            },
            child: Text('Soumettre'),
          ),
        ],
      ),
    );
  }
}
