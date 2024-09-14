import 'dart:collection';
import 'dart:convert';

import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:kachow_app/mqttservice.dart';
import 'package:kachow_app/obdservice.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

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
          await Obdservice.rotinaComandos(connectionB);
        }
      }
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
              onPressed: Mqttservice.TrataMensagemVelocidadeTeste,
              child: const Text('Velocidade'),
            ),
            ElevatedButton(
              onPressed: Mqttservice.TrataMensagemRPMTeste,
              child: const Text('RPM'),
            ),
            ElevatedButton(
              onPressed: Mqttservice.TrataMensagemIntakeTeste,
              child: const Text('Intake'),
            )
          ],
        ),
      ),
    );
  }
}
