import 'package:flutter/services.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:hive/hive.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:kachow_app/Business/Services/RequestFIWAREService.dart';
import 'package:kachow_app/Domain/entities/DadoException.dart';

class NativeService {
  static const MethodChannel channel = MethodChannel('foregroundOBD_service');

  static BluetoothConnection? bluetoothConnection;

  static late Obdservice obdservice;
  static late RequestFIWAREService requestFIWAREService;

  static void initialize() {
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
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'The method ${call.method} is not implemented in Flutter.',
          );
      }
    });
  }

  static void initServices() async {
    obdservice = Obdservice();
    requestFIWAREService = RequestFIWAREService();
    obdservice.instanciarServices();
    await obdservice.iniciarEscuta(bluetoothConnection);
  }

  static Future<void> _coletarDadosOBD() async {
    try {
      if (bluetoothConnection != null) {
        await obdservice.rotinaComandos(bluetoothConnection);
      }
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  static Future<void> _tratarDadosOBD() async {
    try {
      await requestFIWAREService.trataDadosOBD();
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
      await requestFIWAREService.rotinaRequestFIWARE();
    } catch (e, stackTrace) {
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));
    }
  }

  static Future<void> stopServices({bool envioFIWARE = true}) async {
    await bluetoothConnection!.finish();
    bluetoothConnection!.dispose();
    if (envioFIWARE) {
      await requestFIWAREService.RotinaLimpeza();
    }
  }
}
