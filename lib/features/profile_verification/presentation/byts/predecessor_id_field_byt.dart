import 'package:flutter/material.dart';

class PredecessorIdFieldByt extends StatelessWidget {
  final String value;

  const PredecessorIdFieldByt({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: 'Predecessor ID',
        hintText: 'System assigned',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        prefixIcon: const Icon(Icons.link),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
