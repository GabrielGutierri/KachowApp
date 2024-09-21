import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:kachow_app/mqttservice.dart';
import 'package:workmanager/workmanager.dart';

class Obdservice {
  static final Queue<Completer<String>> respostaQueue =
      Queue<Completer<String>>();

  static void iniciarEscuta(BluetoothConnection? connection) {
    connection!.input!.listen((data) {
      Completer<String> completer = respostaQueue.removeFirst();
      String resposta = String.fromCharCodes(data);
      completer.complete(resposta);
    });
  }

  static Future<String> enviarComando(
      String comando, BluetoothConnection? connection) async {
    List<int> list = comando.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);

    Completer<String> completer = Completer<String>();
    respostaQueue.add(completer);
    connection!.output.add(bytes);
    await connection!.output.allSent;

    return completer.future;
  }

  static Future rotinaComandos(BluetoothConnection? connection) async {
    //Velocidade, RPM, Intake manifold pressure, Data
    List<String> listaComandos = [
      "01 0D\r",
      "01 0C\r",
      // "01 0B\r",
    ];

    try {
      //if (connection != null) {
      //iniciarEscuta(connection);
      while (true) {
        await EnviaComandos(listaComandos, connection);
      }
      //}
    } catch (e) {
      print(e);
    }
  }

  static Future<void> EnviaComandos(listaComandos, connection) async {
    await Future.delayed(Duration(seconds: 1));
    // for (var comando in listaComandos) {
    //   String resposta = await enviarComando(comando, connection);
    //   Mqttservice.respostas.add(resposta);
    // }

    await Future.delayed(Duration(seconds: 1));
    await Mqttservice.checkListAndPublish();
    Mqttservice.respostas.clear();
    print(Mqttservice.respostas);
  }
}
