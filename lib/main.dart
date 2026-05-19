import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenhouse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const GreenhousePage(),
    );
  }
}

class GreenhousePage extends StatefulWidget {
  const GreenhousePage({super.key});

  @override
  State<GreenhousePage> createState() => _GreenhousePageState();
}

class _GreenhousePageState extends State<GreenhousePage> {
  double temperature = 0;
  double humidity = 0;
  int soilMoisture = 0;
  bool ledState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Greenhouse'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SensorCard(label: 'Temperature', value: '${temperature.toStringAsFixed(1)} °C'),
            const SizedBox(height: 12),
            _SensorCard(label: 'Humidity', value: '${humidity.toStringAsFixed(1)} %'),
            const SizedBox(height: 12),
            _SensorCard(label: 'Soil Moisture', value: '$soilMoisture %'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LED', style: TextStyle(fontSize: 18)),
                Switch(
                  value: ledState,
                  onChanged: (val) => setState(() => ledState = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String label;
  final String value;

  const _SensorCard({required this.label, required this.value});

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