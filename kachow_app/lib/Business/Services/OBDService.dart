import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kachow_app/Business/Services/GeolocationService.dart';
import 'package:kachow_app/Domain/entities/Acelerometro.dart';
import 'package:kachow_app/Domain/entities/DadoCarro.dart';
import 'package:kachow_app/Domain/entities/Giroscopio.dart';

class Obdservice {
  final Queue<Completer<String>> respostaQueue = Queue<Completer<String>>();
  final Box<DadoCarro> boxDados = Hive.box('tbFilaDados');
  static DateTime? ultimaColetaDados;
  static bool? ELMOcupado;
  StreamSubscription? _ELMSubscription;

  // Variáveis para armazenar dados de geolocalização, acelerômetro e giroscópio
  static double? latitude;
  static double? longitude;
  static double? aceleracaoX;
  static double? aceleracaoY;
  static double? aceleracaoZ;
  static double? giroscopioX;
  static double? giroscopioY;
  static double? giroscopioZ;

  Future iniciarEscuta(BluetoothConnection? connection) async {
    _ELMSubscription = connection!.input!.listen((data) {
      String resposta = String.fromCharCodes(data);
      Completer<String> completer = respostaQueue.removeFirst();
      completer.complete(resposta);
      ultimaColetaDados = DateTime.now();
    });
    // connection!.input!.listen((data) {
    //   String resposta = String.fromCharCodes(data);
    //   Completer<String> completer = respostaQueue.removeFirst();
    //   completer.complete(resposta);
    //   ultimaColetaDados = DateTime.now();
    // });
  }

  Future encerrarEscuta(BluetoothConnection? connection) async {
    await _ELMSubscription?.cancel();
    _ELMSubscription = null;
    ELMOcupado = false;
    ultimaColetaDados = null;
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
    List<String> listaComandos = [
      "01 0D\r", //Velocidade
      "01 0C\r", //RPM
      "01 0B\r", //Pressão do coletor de admissão
      "01 0F\r", //Temperatura do ar de admissão
      "01 04\r", //Engine Load
      "01 11\r" //Throttle Position
    ];

    //if (connection != null) {
    //await iniciarEscuta(connection);
    if (ELMOcupado == false || ELMOcupado == null) {
      ELMOcupado = true;
      await EnviaComandos(listaComandos, connection);
    }
    //}
  }

  Future<void> EnviaComandos(listaComandos, connection) async {
    DadoCarro dadoCarro = DadoCarro();
    dadoCarro.dataColetaDados = DateTime.now();
    for (var comando in listaComandos) {
      String resposta = await enviarComando(comando, connection);
      if (comando == "01 0D\r") dadoCarro.velocidade = resposta;
      if (comando == "01 0C\r") dadoCarro.rpm = resposta;
      if (comando == "01 0B\r") dadoCarro.pressaoColetorAdmissao = resposta;
      if (comando == "01 0F\r") dadoCarro.tempArAdmissao = resposta;
      if (comando == "01 04\r") dadoCarro.engineLoad = resposta;
      if (comando == "01 11\r") dadoCarro.throttlePosition = resposta;
    }
    // Position geolocation = await geolocationService!.obterGeolocation();
    // Acelerometro acelerometro = await geolocationService!.obterAcelerometro();
    // Giroscopio giroscopio = await geolocationService!.obterGiroscopio();
    dadoCarro.latitude = latitude ?? 0;
    dadoCarro.longitude = longitude ?? 0;
    dadoCarro.aceleracaoX = aceleracaoX ?? 0;
    dadoCarro.aceleracaoY = aceleracaoY ?? 0;
    dadoCarro.aceleracaoZ = aceleracaoZ ?? 0;
    dadoCarro.giroscopioX = giroscopioX ?? 0;
    dadoCarro.giroscopioY = giroscopioY ?? 0;
    dadoCarro.giroscopioZ = giroscopioZ ?? 0;
    boxDados.add(dadoCarro);
    ELMOcupado = false;
    print("[${dadoCarro.latitude},${dadoCarro.longitude}]");
  }

  // Método para liberar recursos
  Future<void> dispose() async {
    // Cancela a assinatura do Stream, se houver
    await _ELMSubscription?.cancel();
    _ELMSubscription = null;

    // Limpa a fila de respostas
    while (respostaQueue.isNotEmpty) {
      respostaQueue.removeFirst().completeError(StateError("Disposed"));
    }

    // Reinicia as variáveis estáticas
    ultimaColetaDados = null;
    ELMOcupado = null;
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
      await connection!.finish();
      connection.dispose();
      if (resposta.contains("49 02")) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  instanciarServices() {
    ELMOcupado = false;
    ultimaColetaDados = null;
  }
}
