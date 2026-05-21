import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

import 'widgets/sensor_card.dart';
import 'services/mqtt_service.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 40, 166, 45)),
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
  bool _hasData = false;
  bool _connectionStatus = false;
  bool _isReconnecting = false;
  final MqttService _mqttService = MqttService();



  @override
  void initState() {
    super.initState();
    _mqttService.connect(
      onConnected: () => setState (() { _connectionStatus = true; _isReconnecting = false; }),
      onDisconnected: () => setState(() => _connectionStatus = false),
      onReconnecting: () => setState(() { _connectionStatus = false; _isReconnecting = true; }),
      onMessage: _onMessage,
    );
  }



  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    final msg = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);

    try {
      final data = jsonDecode(payload);
      if (data['temperature'] == null || data['humidity'] == null || data['soil_moisture'] == null) {
        return;
      }

      setState(() {
        temperature = (data['temperature'] as num).toDouble();
        humidity = (data['humidity'] as num).toDouble();
        soilMoisture = (data['soil_moisture'] as num).toInt();
        _hasData = true;
      });
    } catch (error) {
      setState(() => _connectionStatus = false);
    }
  }


  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Greenhouse'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isReconnecting) const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          Icon(
            _connectionStatus ? Icons.wifi : Icons.wifi_off,
            color: _connectionStatus ? Colors.greenAccent : Colors.redAccent
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _hasData ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SensorCard(label: 'Temperature', value: '${temperature.toStringAsFixed(1)} °C'),
            const SizedBox(height: 12),
            SensorCard(label: 'Humidity', value: '${humidity.toStringAsFixed(1)} %'),
            const SizedBox(height: 12),
            SensorCard(label: 'Soil Moisture', value: '$soilMoisture %'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LED', style: TextStyle(fontSize: 18)),
                Switch(
                  value: ledState,
                  onChanged: (val) {
                    setState(() => ledState = val);
                    _mqttService.publishLed(val);
                  },
                ),
              ],
            ),
          ],
        ) : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Waiting for sensor data...'),
            ],
          ),
        ),
      ),
    );
  }
}

