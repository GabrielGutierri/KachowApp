import 'dart:collection';
import 'dart:convert';

import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _BluetoothScreenState(),
    );
  }
}

class _BluetoothScreenState extends StatelessWidget {
  final _device = BluetoothClassic();
  BluetoothConnection? connection;
  final Queue<Completer<String>> respostaQueue = Queue<Completer<String>>();

  void iniciarEscuta() {
    connection!.input!.listen((data) {
      Completer<String> completer = respostaQueue.removeFirst();
      String resposta = String.fromCharCodes(data);
      completer.complete(resposta);
    });
  }

  Future<String> enviarComando(String comando) async {
    List<int> list = comando.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);

    Completer<String> completer = Completer<String>();
    respostaQueue.add(completer);
    connection!.output.add(bytes);
    await connection!.output.allSent;

    return completer.future;
  }

  Future<void> _getPairedDevices() async {
    PermissionStatus bluetoothStatus = await Permission.bluetoothScan.request();
    PermissionStatus bluetoothConnect =
        await Permission.bluetoothConnect.request();
    if (bluetoothStatus.isGranted && bluetoothConnect.isGranted) {
      List<Device> devices = await _device.getPairedDevices();
      Device? obdDevice;
      for (var d in devices) {
        if (d.name.toString() == "OBDII") {
          obdDevice = d;
          break;
        }
      }

      if (obdDevice != null) {
        BluetoothConnection connectionB =
            await BluetoothConnection.toAddress(obdDevice.address);
        if (connectionB.isConnected) {
          connection = connectionB;
        }
      }
    }
  }

  Future<void> _rotinaComandos() async {
    String comandoVelocidade = "01 0D\r";
    List<String> listaComandos = [
      "01 0A\r",
      "01 0B\r",
      "01 0C\r",
      "01 0D\r",
      "01 0E\r"
    ];
    try {
      if (connection != null) {
        iniciarEscuta();
        List<String> respostas = [];
        for (int i = 0; i < 100; i++) {
          for (String comando in listaComandos) {
            String resposta = await enviarComando(comando);
            respostas.add(resposta);
          }
        }
        print(respostas);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _testarHTTP() async {
    final url =
        'http://46.17.108.131:1026/v2/entities/urn:ngsi-ld:carroHttp:01/attrs/velocidade/value';

    try {
      final velocidades = ["1", "2", "3", "4", "5"];

      for (var velocidade in velocidades) {
        final response = await http.put(
          Uri.parse(url),
          headers: {'fiware-service': 'smart', 'fiware-servicepath': '/'},
          body: velocidade,
        );
        print(response);
      }
    } catch (error) {
      print('Error sending command: $error');
    }
  }

  Future<void> _testarMQTT() async {
    final client =
        MqttServerClient.withPort("46.17.108.131", "vascodagama", 1883);
    client.logging(on: true); // Para ajudar na depuração
    client.keepAlivePeriod = 20; // Período de keep alive em segundos

    // Configuração da mensagem de conexão
    final connMessage = MqttConnectMessage()
        .withClientIdentifier("vascodagama")
        .startClean() // Inicia uma sessão limpa
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    // Tente conectar ao broker
    try {
      print('Conectando ao broker...');
      await client.connect();
    } catch (e) {
      print('Erro de conexão: $e');
      client.disconnect();
      return; // Saia se não conseguir conectar
    }

    // Verifique se a conexão foi estabelecida
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Conectado ao broker MQTT');

      // Defina o tópico e a mensagem que você quer enviar
      String topic = 'TEF/carroMqtt01/attrs/v';

      // Criação da mensagem a ser publicada
      final velocidades = ['1', '2', '3', '4', '5'];
      for (var velocidade in velocidades) {
        final builder = MqttClientPayloadBuilder();
        builder.addUTF8String(velocidade);

        // Publica a mensagem no tópico
        client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      }
    } else {
      print('Falha na conexão, status: ${client.connectionStatus}');
      client.disconnect();
    }

    // Desconecte após a publicação
    client.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TesteBluetooth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _getPairedDevices,
              child: const Text('Conectar'),
            ),
            ElevatedButton(
                onPressed: _rotinaComandos,
                child: const Text('Enviar comandos')),
            ElevatedButton(
                onPressed: _testarHTTP, child: const Text('Testar HTTP')),
            ElevatedButton(
                onPressed: _testarMQTT, child: const Text('Testar MQTT'))
          ],
        ),
      ),
    );
  }
}
