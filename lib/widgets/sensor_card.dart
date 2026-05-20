import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String label;
  final String value;

  const SensorCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}