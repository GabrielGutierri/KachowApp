import 'package:flutter/material.dart';
import 'package:kachow_app/Business/Controllers/BluetoothController.dart';

class BluetoothPage extends StatelessWidget {
  final BluetoothController _bluetoothController;

  BluetoothPage(this._bluetoothController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TesteBluetooth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _bluetoothController.GetPairedDevices,
              child: const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }
}
