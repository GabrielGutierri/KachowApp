import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:kachow_app/Business/Services/NativeService.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:kachow_app/Business/Services/RequestFIWAREService.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController {
  final Obdservice _obdservice;

  BluetoothController(this._obdservice);

  final _device = BluetoothClassic();
  final FlutterBlueClassic bluePlugin = FlutterBlueClassic();
  Device? _dispositivoOBD = null;

  Future rotinaComandos() async {
    BluetoothConnection? newConnection =
        await bluePlugin.connect(_dispositivoOBD!.address);
    NativeService.bluetoothConnection = newConnection;
    await NativeService.initServices();
    Obdservice.idCorrida = await RequestFIWAREService.ultimoIdCorrida();
  }

  Future<List<Device>> ObterDispositivosPareados() async {
    PermissionStatus bluetoothStatus = await Permission.bluetoothScan.request();
    PermissionStatus bluetoothConnect =
        await Permission.bluetoothConnect.request();

    List<Device> devices = List.empty();
    if (bluetoothStatus.isGranted && bluetoothConnect.isGranted) {
      devices = await _device.getPairedDevices();
    }
    return devices;
  }

  Future<String> testarComandoOBD(String comando) async {
    BluetoothConnection? newConnection =
        await bluePlugin.connect(_dispositivoOBD!.address);

    String resposta = await _obdservice.testaComandoOBD(comando, newConnection);
    await newConnection!.finish();
    newConnection.dispose();
    return resposta;
  }

  Future<bool> VerificarConexaoOBD() async {
    try {
      BluetoothConnection? newConnection =
          await bluePlugin.connect(_dispositivoOBD!.address);
      await _obdservice.iniciarEscuta(newConnection);

      for (var i = 0; i < 10; i++) {
        try {
          String resposta = await _obdservice
              .enviarComando("01 0D", newConnection)
              .timeout(Duration(seconds: 3));
        } catch (ex) {
          if (i == 9) {
            await newConnection!.finish();
            newConnection.dispose();
            return false;
          }
        }
      }
      await newConnection!.finish();
      newConnection.dispose();
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> ConectarAoDispositivo(Device dispositivo) async {
    try {
      BluetoothConnection? connectionB =
          await bluePlugin.connect(dispositivo.address);
      if (connectionB!.isConnected) {
        bool dispositivoOBD = await _obdservice.TestarConexaoELM(connectionB);

        if (dispositivoOBD) {
          _dispositivoOBD = dispositivo;
          return true;
        }
      }
      return false;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> VerificarBluetoothLigado() async {
    bool status = await bluePlugin.isEnabled;
    return status;
  }
}
