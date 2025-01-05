import 'package:flutter/services.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:hive/hive.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:kachow_app/Business/Services/RequestFIWAREService.dart';
import 'package:kachow_app/Business/Services/GeolocationService.dart';
import 'package:kachow_app/Domain/entities/DadoException.dart';

class NativeService {
  static const MethodChannel channel = MethodChannel('foregroundOBD_service');

  static BluetoothConnection? bluetoothConnection;
  static late String dispositivoAddress;
  static late Obdservice obdservice;
  static late GeolocationService geolocationService;
  static late RequestFIWAREService requestFIWAREService;
  static bool monitorDisponivel = true;
  static bool foreGroundParou = false;
  static final FlutterBlueClassic bluePlugin = FlutterBlueClassic();

  static Future initialize() async {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'coletarDadosOBD':
          await _coletarDadosOBD();
          break;
        case 'tratarDadosOBD':
          await _tratarDadosOBD();
          break;
        case 'enviarDadosFIWARE':
          await _enviarDadosFIWARE();
          break;
        case 'coletarDadosGeolocalizao':
          await _coletarDadosGeolocalizao();
          break;
        case 'monitoraConexaoBluetooth':
          await _monitoraConexaoBluetooth();
          break;
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'The method ${call.method} is not implemented in Flutter.',
          );
      }
    });
  }

  static Future<void> initServices() async {
    obdservice = Obdservice();
    requestFIWAREService = RequestFIWAREService();
    await requestFIWAREService.setDeviceName();
    geolocationService = GeolocationService();
    await geolocationService.initializeSensors();
    obdservice.instanciarServices();
    await obdservice.iniciarEscuta(bluetoothConnection);
    foreGroundParou = false;
  }

  static Future<void> _coletarDadosOBD() async {
    try {
      if (!foreGroundParou) {
        if (bluetoothConnection != null) {
          await obdservice.rotinaComandos(bluetoothConnection);
        }
      }
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  static Future<void> _coletarDadosGeolocalizao() async {
    try {
      if (!foreGroundParou) {
        await geolocationService.getDadosGeolocalizacao();
      }
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  static Future<void> _tratarDadosOBD() async {
    try {
      if (!foreGroundParou) {
        await requestFIWAREService.trataDadosOBD();
        print("trata dados");
      }
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  static Future<void> _enviarDadosFIWARE() async {
    try {
      if (!foreGroundParou) {
        await requestFIWAREService.rotinaRequestFIWARE();
        print("envio dados");
      }
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  static Future<void> stopServices({bool envioFIWARE = true}) async {
    try {
      if (bluetoothConnection != null) {
        await bluetoothConnection!.finish();
        bluetoothConnection!.dispose();
      }
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
    if (envioFIWARE == true) {
      await requestFIWAREService.RotinaLimpeza();
    }
  }

  static Future<void> _monitoraConexaoBluetooth() async {
    try {
      if (monitorDisponivel == true) {
        if (Obdservice.ultimaColetaDados == null ||
            DateTime.now()
                    .difference(Obdservice.ultimaColetaDados as DateTime)
                    .inSeconds >=
                60) {
          monitorDisponivel = false;
          foreGroundParou = true;
          await obdservice.encerrarEscuta(bluetoothConnection);
          await stopServices(envioFIWARE: false);
          await Future.delayed(Duration(seconds: 3));
          BluetoothConnection? connection = null;
          int retryConnection = 0;
          bool sucesso = false;
          while (retryConnection < 10 && sucesso == false) {
            try {
              connection = await bluePlugin.connect(dispositivoAddress);
              await Future.delayed(Duration(seconds: 3));
              if (connection!.isConnected == true) {
                sucesso = true;
              } else {
                sucesso = false;
                retryConnection += 1;
              }
            } catch (ex) {
              sucesso = false;
              retryConnection += 1;
            }
          }
          sucesso = true;
          if (sucesso == true) {
            bluetoothConnection = connection;
            await Future.delayed(Duration(seconds: 3));
            await obdservice.dispose();
            await initServices();
            //await platform.invokeMethod('restartExampleService');
            print('VORTOU');
          } else {
            throw new Exception("ERRO NO RETRY DO BLUETOOTH");
          }
          monitorDisponivel = true;
        }
      }
    } catch (ex) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: "Erro rotina de comandos - ${ex.toString()}",
          stackTrace: "",
          data: DateTime.now()));
    }
  }
}
