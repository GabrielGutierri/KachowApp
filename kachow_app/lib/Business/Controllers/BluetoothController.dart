import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:kachow_app/Business/Services/NativeService.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
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
}
