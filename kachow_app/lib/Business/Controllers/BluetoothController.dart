import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController {
  final Obdservice _obdservice;

  BluetoothController(this._obdservice);

  final _device = BluetoothClassic();
  BluetoothConnection? _connection = null;

  Future<void> GetPairedDevices() async {
    PermissionStatus bluetoothStatus = await Permission.bluetoothScan.request();
    PermissionStatus bluetoothConnect =
        await Permission.bluetoothConnect.request();
    if (bluetoothStatus.isGranted && bluetoothConnect.isGranted) {
      List<Device> devices = await _device.getPairedDevices();
      Device? obdDevice;
      for (var d in devices) {
        if (d.name.toString() == "OBDII") {
          obdDevice = d;
          break;
        }
      }

      if (obdDevice != null) {
        BluetoothConnection connectionB =
            await BluetoothConnection.toAddress(obdDevice.address);
        if (connectionB.isConnected) {
          var connectionB;
          await _obdservice.rotinaComandos(connectionB);
        }
      }
    }
  }

  Future rotinaComandos() async {
    BluetoothConnection? newConnection = _connection;
    await _obdservice.rotinaComandos(newConnection);
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

  Future<bool> ConectarAoDispositivo(Device dispositivo) async {
    BluetoothConnection connectionB =
        await BluetoothConnection.toAddress(dispositivo.address);
    if (connectionB.isConnected) {
      bool dispositivoOBD = await _obdservice.TestarConexaoELM(connectionB);
      if (dispositivoOBD) {
        _connection = connectionB;
        return true;
      }
    }
    _connection = null;
    return false;
  }
}
