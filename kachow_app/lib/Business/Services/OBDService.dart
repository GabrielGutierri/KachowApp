import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:kachow_app/Business/Services/GeolocationService.dart';
import 'package:kachow_app/Business/Services/MQTTService.dart';

class Obdservice {
  final Queue<Completer<String>> respostaQueue = Queue<Completer<String>>();

  final Mqttservice _mqttservice;
  final GeolocationService _geolocationService;

  Obdservice(this._mqttservice, this._geolocationService);

  void iniciarEscuta(BluetoothConnection? connection) {
    connection!.input!.listen((data) {
      Completer<String> completer = respostaQueue.removeFirst();
      String resposta = String.fromCharCodes(data);
      completer.complete(resposta);
    });
  }

  Future<String> enviarComando(
      String comando, BluetoothConnection? connection) async {
    List<int> list = comando.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);

    Completer<String> completer = Completer<String>();
    respostaQueue.add(completer);
    connection!.output.add(bytes);
    await connection.output.allSent;

    return completer.future;
  }

  Future rotinaComandos(BluetoothConnection? connection) async {
    //Velocidade, RPM, Intake manifold pressure, Data
    List<String> listaComandos = [
      "01 0D\r",
      "01 0C\r",
      // "01 0B\r",
    ];

    try {
      if (connection != null) {
        iniciarEscuta(connection);
        while (true) {
          await EnviaComandos(listaComandos, connection);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> EnviaComandos(listaComandos, connection) async {
    await Future.delayed(Duration(seconds: 1));

    String geolocalizacao =
        await _geolocationService.TrataMensagemGeolocalizacao();
    String latitude = "LAT" + geolocalizacao.split(";")[0];
    String longitude = "LON" + geolocalizacao.split(";")[1];
    Mqttservice.respostas.add(latitude);
    Mqttservice.respostas.add(longitude);

    for (var comando in listaComandos) {
      String resposta = await enviarComando(comando, connection);
      Mqttservice.respostas.add(resposta);
    }

    await Future.delayed(Duration(seconds: 1));
    await _mqttservice.checkListAndPublish();
    Mqttservice.respostas.clear();
    print(Mqttservice.respostas);
  }
}