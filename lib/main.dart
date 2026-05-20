import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'secrets.dart';
import 'dart:convert';

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

  late MqttServerClient _client;

  @override
  void initState() {
    super.initState();
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    _client = MqttServerClient('ws://$mqttServer', 'greenhouse-app');
    _client.port = 9001;
    _client.useWebSocket = true;
    _client.keepAlivePeriod = 60;
    _client.connectionMessage = MqttConnectMessage()
      .authenticateAs(mqttUser, mqttPassword)
      .startClean();

    _client.autoReconnect = true;
    _client.onAutoReconnect = () {
      setState(() => _connectionStatus = false);
      _connectionStatus = false;
      _isReconnecting = true;
    };
    _client.onAutoReconnected = () {
      setState(() => _connectionStatus = true);
      _connectionStatus = true;
      _isReconnecting = false;
    };

    try {
      await _client.connect(mqttUser, mqttPassword);
      setState(() => _connectionStatus = true);
      _client.subscribe('$mqttTopic/sensor', MqttQos.atLeastOnce);
      _client.updates!.listen(_onMessage);
    } catch (error) {
      setState(() => _connectionStatus = false);
    }
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

  void _publishLed(bool state) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(state ? 'true' : 'false');
    _client.publishMessage('$mqttTopic/command/led', MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  void dispose() {
    _client.disconnect();
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
                  onChanged: (val) {
                    setState(() => ledState = val);
                    _publishLed(val);
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