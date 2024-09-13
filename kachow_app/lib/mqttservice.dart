// Background task identifier
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:workmanager/workmanager.dart';

const String mqttTask = "mqttTask";

// Simulated list of data
List<String> dataList = ["Message 1"];

// Setup MQTT Client
Future<MqttServerClient> setupMqtt() async {
  final client =
      MqttServerClient.withPort("46.17.108.131", "vascodagama", 1883);
  client.logging(on: true);
  client.keepAlivePeriod = 20;
  final connMessage = MqttConnectMessage()
      .withClientIdentifier("vascodagama")
      .startClean()
      .withWillQos(MqttQos.atMostOnce);
  client.connectionMessage = connMessage;

  try {
    await client.connect();
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Conectado ao broker MQTT');
    } else {
      print('Falha na conexão');
      client.disconnect();
    }
  } catch (e) {
    print('Erro de conexão: $e');
    client.disconnect();
  }

  return client;
}

// Publish MQTT message
void publishMqttMessage(MqttServerClient client, String message) {
  String topic = 'TEF/carroMqtt01/attrs/v';
  final builder = MqttClientPayloadBuilder();
  builder.addUTF8String(message);
  client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  print('Mensagem publicada: $message');
}

// Function to check list and publish if necessary
Future<void> checkListAndPublish() async {
  // Setup MQTT
  final client = await setupMqtt();

  // Publish each message in the list
  for (var message in dataList) {
    publishMqttMessage(client, message);
  }

  // Disconnect the MQTT client
  client.disconnect();
}

// WorkManager callback to execute periodically in the background
void mqttTaskCallback() {
  Workmanager().executeTask((task, inputData) async {
    // int i = 0;
    while (true) {
      await checkListAndPublish();
    }
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager
  Workmanager().initialize(mqttTaskCallback, isInDebugMode: true);

  // Register the periodic task (every 15 minutes in this case)
  Workmanager().registerPeriodicTask(
    "1",
    mqttTask,
    frequency: Duration(minutes: 15),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('MQTT Background Service')),
        body: Center(child: Text('Running background task...')),
      ),
    );
  }
}
