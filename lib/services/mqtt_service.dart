import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../secrets.dart';

class MqttService {
  late MqttServerClient _client;

  Future<void> connect({
    required Function onConnected,
    required Function onDisconnected,
    required Function onReconnecting,
    required Function(List<MqttReceivedMessage<MqttMessage>>) onMessage,
  }) async {
    _client = MqttServerClient('ws://$mqttServer', 'greenhouse-app');
    _client.port = 9001;
    _client.useWebSocket = true;
    _client.keepAlivePeriod = 60;
    _client.connectionMessage = MqttConnectMessage()
        .authenticateAs(mqttUser, mqttPassword)
        .startClean();

    _client.autoReconnect = true;
    _client.onAutoReconnect = () => onReconnecting();
    _client.onAutoReconnected = () => onConnected();

    try {
      await _client.connect(mqttUser, mqttPassword);
      onConnected();
      _client.subscribe('$mqttTopic/sensor', MqttQos.atLeastOnce);
      _client.updates!.listen(onMessage);
    } catch (error) {
      onDisconnected();
    }
  }

   void publishLed(bool state) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(state ? 'true' : 'false');
    _client.publishMessage('$mqttTopic/command/led', MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    _client.disconnect();
  }
}

