import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kachow_app/Business/Controllers/BluetoothController.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:kachow_app/Business/Services/NativeService.dart';

class BluetoothPage extends StatefulWidget {
  final BluetoothController _bluetoothController;

  BluetoothPage(this._bluetoothController);

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  static const platform = const MethodChannel('foregroundOBD_service');
  String _serverState = 'Did not make the call yet';

  Future<void> _startService() async {
    try {
      final result = await platform.invokeMethod('startForegroundService');
      setState(() {
        _serverState = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  Future<void> _stopService() async {
    try {
      final result = await platform.invokeMethod('stopForegroundService');
      setState(() {
        _serverState = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  bool bluetoothValido = false;
  bool comandosIniciados = false;

  final TextEditingController _comandoOBDController = TextEditingController();

  String _montaTextoDispositivo(Device dispositivo) {
    if (dispositivo.name!.isEmpty) {
      return "Dispositivo Desconhecido";
    }
    return dispositivo.name!;
  }

  Future<void> _rotinaConexaoBluetooth(
      Device dispositivo, BuildContext context) async {
    try {
      bool conectado =
          await widget._bluetoothController.ConectarAoDispositivo(dispositivo);
      //bool conectado = true;
      if (!conectado) {
        _exibirMensagemErro(
            context, 'Erro ao conectar ao dispositivo Bluetooth.');
      } else {
        // Quando a conexão for bem-sucedida, atualizar o estado da página
        setState(() {
          bluetoothValido = true;
          comandosIniciados = false;
        });
        Navigator.of(context).pop(); // Fecha o modal após a conexão
      }
    } catch (e) {
      _exibirMensagemErro(
          context, 'Erro ao conectar ao dispositivo Bluetooth.');
    }
  }

  void _exibirMensagemErro(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(mensagem),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> IniciarRotinaComandos() async {
    try {
      await widget._bluetoothController.rotinaComandos();
      await _startService();
      setState(() {
        bluetoothValido = true;
        comandosIniciados = true;
      });
    } catch (e) {
      _exibirMensagemErro(context, 'Erro');
    }
  }

  Future<void> PararRotinaComandos() async {
    try {
      await NativeService.stopServices();
      await _stopService();
      setState(() {
        comandosIniciados = false;
      });
    } catch (ex) {
      _exibirMensagemErro(context, 'Erro');
    }
  }

  Future<void> _testarComandoOBD(BuildContext context) async {
    var comando = _comandoOBDController.text;
    var resposta = await widget._bluetoothController.testarComandoOBD(comando);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resposta'),
          content: Text(resposta),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> exibirModalDispositivos(BuildContext context) async {
    // Supondo que você tenha uma função para obter os dispositivos pareados
    List<Device> dispositivosBluetooth =
        await widget._bluetoothController.ObterDispositivosPareados();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecione um dispositivo Bluetooth'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dispositivosBluetooth.length,
              itemBuilder: (context, index) {
                Device dispositivo = dispositivosBluetooth[index];
                return ListTile(
                  title: Text(_montaTextoDispositivo(dispositivo),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _rotinaConexaoBluetooth(dispositivo, context);
                    },
                    child: Text("Conectar", textAlign: TextAlign.center),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> TestarComando(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Testar um comando OBD'),
          content: Column(
            children: [
              TextField(
                controller: _comandoOBDController,
                decoration: const InputDecoration(labelText: 'Comando OBD'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _testarComandoOBD(context);
                },
                child: const Text('Testar'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexão Bluetooth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!bluetoothValido)
              ElevatedButton(
                onPressed: () {
                  exibirModalDispositivos(context);
                },
                child: const Text('Conectar'),
              )
            else if (bluetoothValido && !comandosIniciados) ...[
              ElevatedButton(
                onPressed: () async {
                  await IniciarRotinaComandos();
                },
                child: const Text('Enviar comandos'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await TestarComando(context);
                },
                child: const Text('Testar um comando'),
              )
            ] else if (bluetoothValido && comandosIniciados) ...[
              ElevatedButton(
                onPressed: () async {
                  await PararRotinaComandos();
                },
                child: const Text('Parar comandos'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await TestarComando(context);
                },
                child: const Text('Testar um comando'),
              )
            ],
          ],
        ),
      ),
    );
  }
}
