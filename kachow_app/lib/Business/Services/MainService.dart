import 'dart:async';

import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:hive/hive.dart';
import 'package:kachow_app/Business/Services/FiwareService.dart';
import 'package:kachow_app/Business/Services/GeolocationService.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:kachow_app/Domain/entities/DadoException.dart';

class MainService {
  final GeolocationService geoService = GeolocationService();
  final Obdservice obdService = Obdservice();
  final Fiwareservice fiwareService = Fiwareservice();
  BluetoothConnection? connection;
  StreamSubscription? obdSubscription;
  StreamSubscription? acelerometroSubscription;
  StreamSubscription? geolocalizacaoSubscription;

  MainService({required this.connection});

  Future<void> startAllServices() async {
    await geoService
        .obterGeolocation(); //vou adicionar uma geolocalizacao, pois o serviço só vai pegar daqui 8sec
    await obdService.iniciarEscuta(connection);
    obdSubscription = Stream.periodic(Duration(seconds: 1))
        .asyncMap((_) => coletarDadosOBD())
        .listen((_) {});

    acelerometroSubscription = Stream.periodic(Duration(seconds: 1))
        .asyncMap((_) => coletarDadosAcelerometro())
        .listen((_) {});

    geolocalizacaoSubscription = Stream.periodic(Duration(seconds: 8))
        .asyncMap((_) => coletarDadosGeolocalizacao())
        .listen((_) {});
  }

  Future<void> coletarDadosOBD() async {
    try {
      if (connection != null) {
        await obdService.iniciarServico(connection);
      }
    } catch (e, stackTrace) {
      // var boxException = await Hive.openBox<DadoException>('tbException');
      // boxException.add(new DadoException(
      //     mensagem: e.toString(),
      //     stackTrace: stackTrace.toString(),
      //     data: DateTime.now()));
    }
  }

  Future<void> coletarDadosAcelerometro() async {
    try {
      await geoService.obterAcelerometro();
    } catch (e, stackTrace) {
      // var boxException = await Hive.openBox<DadoException>('tbException');
      // boxException.add(new DadoException(
      //     mensagem: e.toString(),
      //     stackTrace: stackTrace.toString(),
      //     data: DateTime.now()));
    }
  }

  Future<void> coletarDadosGeolocalizacao() async {
    try {
      await geoService.obterGeolocation();
    } catch (e, stackTrace) {
      // var boxException = await Hive.openBox<DadoException>('tbException');
      // boxException.add(new DadoException(
      //     mensagem: e.toString(),
      //     stackTrace: stackTrace.toString(),
      //     data: DateTime.now()));
    }
  }

  Future<void> preencheTabelaFIWARE() async {
    //ficar vendo conexao com internet para enviar. Se não tiver depois de um tempo, matar todos os dados
    await fiwareService.preencheTabelaFIWARE();
  }

  Future<void> stopAllServices() async {
    try {
      obdSubscription?.cancel();
      acelerometroSubscription?.cancel();
      geolocalizacaoSubscription?.cancel();
      //cancelar a conexao com o Bluetooth;
      await connection!.finish();
      connection!.dispose();

      await preencheTabelaFIWARE();
    } catch (ex) {
      print(ex);
    }
  }
}
