import 'dart:async';

import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:hive/hive.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:kachow_app/Business/Services/RequestFIWAREService.dart';
import 'package:kachow_app/Domain/entities/DadoException.dart';

class MainService {
  final Obdservice obdService = Obdservice();
  final RequestFIWAREService requestFiware = RequestFIWAREService();

  BluetoothConnection? connection;
  StreamSubscription? obdSubscription;
  StreamSubscription? tratativaDadosSubscription;
  StreamSubscription? requestFiwareSubscription;

  MainService({required this.connection});

  Future<void> startAllServices() async {
    await obdService.iniciarEscuta(connection);
    await obdService.instanciarServices();
    await requestFiware.setDeviceName();

    obdSubscription = Stream.periodic(Duration(seconds: 1))
        .asyncMap((_) => coletarDadosOBD())
        .listen((_) {});
    tratativaDadosSubscription = Stream.periodic(Duration(seconds: 5))
        .asyncMap((_) => tratarDadosOBD())
        .listen((_) {});

    requestFiwareSubscription = Stream.periodic(Duration(seconds: 15))
        .asyncMap((_) => enviarDadosFIWARE())
        .listen((_) {});
    //Mudança 09/11: vou coletar tudo de uma vez, para deixar as coisas mais
    //simples com problemas de sincronização por ora
  }

  Future<void> coletarDadosOBD() async {
    try {
      if (connection != null) {
        await obdService.iniciarServico(connection);
      }
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  Future<void> tratarDadosOBD() async {
    try {
      await requestFiware.trataDadosOBD();
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  Future<void> enviarDadosFIWARE() async {
    try {
      await requestFiware.rotinaRequestFIWARE();
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  Future<void> stopAllServices() async {
    try {
      obdSubscription?.cancel();
      tratativaDadosSubscription?.cancel();
      requestFiwareSubscription?.cancel();
      //cancelar a conexao com o Bluetooth;
      await connection!.finish();
      connection!.dispose();

      await requestFiware.RotinaLimpeza();
    } catch (ex) {
      print(ex);
    }
  }
}
