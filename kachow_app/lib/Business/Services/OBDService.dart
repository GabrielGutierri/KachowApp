import 'dart:async';
import 'dart:collection';
import 'dart:io';
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

  Future<void> testarHttp() async {
    while (true) {
      await _httpService.testarHTTP();
      var duracao = const Duration(seconds: 5);
      sleep(duracao);
    }
  }

  Future rotinaComandos(BluetoothConnection? connection) async {
    List<String> listaComandos = [
      "01 0D\r", //Velocidade
      "01 0C\r", //RPM
      "01 0B\r", //Pressão do coletor de admissão
      "01 0F\r", //Temperatura do ar de admissão
      "01 04\r", //Engine Load
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

    String dataColetaDados = DateTime.now().toString();
    HttpService.respostas.add(dataColetaDados);
    // Obtém coordenadas no formato [longitude, latitude]
    List<double> geolocalizacao =
        await _geolocationService.TrataMensagemGeolocalizacao();
    String geolocation =
        "GEO${geolocalizacao[0]}" + ";" + "${geolocalizacao[1]}";
    HttpService.respostas.add(geolocation);

    // Obtém a aceleração usando o GPS
    double aceleracao = await _geolocationService.calculaAceleracaoSensor();
    HttpService.respostas.add("ACE$aceleracao");

    // Giroscopio
    double giroscopio = await _geolocationService.calcularOrientacao();
    HttpService.respostas.add("GIR$giroscopio");


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
    String comandoEditado = comando + "\r";
    await iniciarEscuta(connection);
    return await enviarComando(comandoEditado, connection);
  }

  Future<bool> TestarConexaoELM(BluetoothConnection? connection) async {
    try {
      String comando = "09 02\r";
      await iniciarEscuta(connection);
      String resposta = await enviarComando(comando, connection);

      if (resposta.contains("49 02")) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
