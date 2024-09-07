import 'dart:collection';
import 'dart:convert';

import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

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
                child: const Text('Enviar comandos'))
          ],
        ),
      ),
    );
  }
}
