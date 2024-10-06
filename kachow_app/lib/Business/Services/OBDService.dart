import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:kachow_app/Business/Services/GeolocationService.dart';
import 'package:kachow_app/Business/Services/HTTPService.dart';

class Obdservice {
  final Queue<Completer<String>> respostaQueue = Queue<Completer<String>>();

  final HttpService _httpService;
  final GeolocationService _geolocationService;

  Obdservice(this._httpService, this._geolocationService);

  Future iniciarEscuta(BluetoothConnection? connection) async {
    connection!.input!.listen((data) {
      String resposta = String.fromCharCodes(data);
      Completer<String> completer = respostaQueue.removeFirst();
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
        await iniciarEscuta(connection);
        while (true) {
          await EnviaComandos(listaComandos, connection);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> EnviaComandos(listaComandos, connection) async {
    await Future.delayed(const Duration(seconds: 5));

    // Obtém coordenadas no formato [longitude, latitude]
    List<double> geolocalizacao = await _geolocationService.TrataMensagemGeolocalizacao();
    String geolocation = "GEO${geolocalizacao[0]}"+";"+"${geolocalizacao[1]}";
    HttpService.respostas.add(geolocation);

    // Obtém a aceleração usando o GPS
    double aceleracao = await _geolocationService.calculaAceleracaoSensor();
    HttpService.respostas.add("ACE$aceleracao");

    for (var comando in listaComandos) {
      String resposta = await enviarComando(comando, connection);
      HttpService.respostas.add(
          resposta); //vale a pensa mudar para salvar na memoria, ao inves de uma fila?
  }

    //todas as respostas estão no array
    try {
      await Future.delayed(const Duration(seconds: 5));
      await _httpService.checkListAndPublish();
      HttpService.respostas.clear();
    } catch (e) {
      HttpService.respostas.clear();
    }
  }

  Future<String> testaComandoOBD(
      String comando, BluetoothConnection? connection) async {
    return await enviarComando(comando, connection);
  }

  Future<bool> TestarConexaoELM(BluetoothConnection? connection) async {
    try {
      String comando = "09 02\r";
      await iniciarEscuta(connection);
      String resposta = await enviarComando(comando, connection);

      if (resposta.contains("09 02")) {
        print(resposta);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
