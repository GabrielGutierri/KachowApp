import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kachow_app/Business/Controllers/BluetoothController.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:kachow_app/Business/Services/NativeService.dart';
import 'package:kachow_app/Business/Utils/MetodosUtils.dart';

class BluetoothPage extends StatefulWidget {
  final BluetoothController _bluetoothController;

  BluetoothPage(this._bluetoothController);

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  static const platform = const MethodChannel('foregroundOBD_service');
  String _serverState = 'Did not make the call yet';

  Timer? timer;
  bool? statusConexaoELM;
  bool? statusForeground;

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

  Future PararServicoFIWARE(BuildContext context, bool envioFIWARE) async {
    if (envioFIWARE) {
      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        barrierDismissible: false, // Evita fechar ao clicar fora
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black87, // Cor do fundo do diálogo
            elevation: 8, // Elevação do diálogo
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Bordas arredondadas
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16), // Espaço entre o spinner e o texto
                Text(
                  'Sincronizando dados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );
      try {
        await NativeService.stopServices(envioFIWARE: true);
      } finally {
        Navigator.of(context).pop();
      }
    } else {
      await NativeService.stopServices(envioFIWARE: false);
      _exibirMensagemErro(context,
          "Não foi possível sincronizar os dados com o FIWARE... o aplicativo tentará novamente quando você entrar de novo!");
    }
  }

  Future<void> _stopService(BuildContext context) async {
    try {
      final result = await platform.invokeMethod('stopForegroundService');
      NativeService.foreGroundParou = true;
      bool conexaoComInternet = await Metodosutils.VerificaConexaoInternet();
      if (conexaoComInternet) {
        await PararServicoFIWARE(context, true);
      } else {
        await PararServicoFIWARE(context, false);
      }
      setState(() {
        _serverState = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  bool bluetoothValido = false;
  bool comandosIniciados = false;
  bool bluetoothVerificado = false;

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
        await widget._bluetoothController.salvarUltimoDispositivo(dispositivo.address);

        setState(() {
          bluetoothValido = true;
          comandosIniciados = false;
        });
        Navigator.of(context).pop(); // Fecha o modal após a conexão

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sucesso'),
              content: Text("Dispositivo conectado com sucesso!"),
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
    } catch (e) {
      _exibirMensagemErro(
          context, 'Erro ao conectar ao dispositivo Bluetooth.');
    }
  }



  Future<void> _rotinaConexaoBluetoothDispositivoEncontrado(
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
        await widget._bluetoothController.salvarUltimoDispositivo(dispositivo.address);

        setState(() {
          bluetoothValido = true;
          comandosIniciados = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sucesso'),
              content: Text("Dispositivo conectado com sucesso!"),
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

  Future<void> IniciarRotinaComandos(BuildContext context) async {
    try {
      bool bluetoothLigado =
          await widget._bluetoothController.VerificarBluetoothLigado();
      if (!bluetoothLigado) {
        _exibirMensagemErro(context, 'Atenção! Bluetooth não está ligado!');
        return;
      }

      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        barrierDismissible: false, // Evita fechar ao clicar fora
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black87, // Cor do fundo do diálogo
            elevation: 8, // Elevação do diálogo
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Bordas arredondadas
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16), // Espaço entre o spinner e o texto
                Text(
                  'Verificando dispositivo OBD',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );
      bool obdOK = false;
      try {
        obdOK = await widget._bluetoothController.VerificarConexaoOBD();
      } finally {
        Navigator.of(context).pop();
      }
      if (!obdOK) {
        _exibirMensagemErro(context,
            "Atenção! OBD não está respondendo, verifique ele ou tente novamente!");
        return;
      }
      await widget._bluetoothController.rotinaComandos();
      await _startService();
      setState(() {
        bluetoothValido = true;
        comandosIniciados = true;
      });

      timer = Timer.periodic(Duration(seconds: 5), (_) {
        _checkStatus();
      });
    } catch (e) {
      _exibirMensagemErro(context, 'Erro desconhecido ao iniciar a corrida');
    }
  }

  Future<void> PararRotinaComandos(BuildContext context) async {
    try {
      // await NativeService.stopServices();
      await _stopService(context);
      setState(() {
        comandosIniciados = false;
      });
      timer?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sucesso'),
            content: Text("Corrida encerrada com sucesso!"),
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
    } catch (ex) {
      _exibirMensagemErro(context, 'Erro desconhecido ao encerrar a corrida');
    }
  }

  void _checkStatus() async {
    bool conexaoELM =
        (NativeService.bluetoothConnection == null) ? false : true;
    bool foregroundRodando =
        (NativeService.foreGroundParou == true) ? false : true;
    // bool conexaoELM = true;
    // bool foregroundRodando = true;
    setState(() {
      statusConexaoELM = conexaoELM;
      statusForeground = foregroundRodando;
    });
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

  Future<void> _verificarUltimoDispositivo() async {
    List<Device> dispositivos = await widget._bluetoothController.ObterDispositivosPareados();
    String? ultimoDispositivo = await widget._bluetoothController.obterUltimoDispositivo();
    bluetoothVerificado = true;

    if (ultimoDispositivo != null) {
      Device? dispositivoEncontrado = dispositivos.firstWhere(
        (device) => device.address == ultimoDispositivo,
        orElse: () => null as Device, // Cast para evitar erro
      );
      if (dispositivoEncontrado != null) {
        await _rotinaConexaoBluetoothDispositivoEncontrado(dispositivoEncontrado, context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _inicializarBluetooth();
  }

  void _inicializarBluetooth() async {
    if (!bluetoothVerificado) {
      await _verificarUltimoDispositivo();
      setState(() {}); // Atualiza a UI após a verificação
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexão Bluetooth'),
      ),
      body: bluetoothVerificado
          ? _buildMainContent()
          : Center(child: CircularProgressIndicator()), // Mostra um indicador de carregamento enquanto verifica
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        Center(
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
                    await IniciarRotinaComandos(context);
                  },
                  child: const Text('Iniciar Corrida'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await TestarComando(context);
                  },
                  child: const Text('Testar um comando'),
                )
              ] else if (bluetoothValido && comandosIniciados) ...[
                CircularProgressIndicator(),
                ElevatedButton(
                  onPressed: () async {
                    await PararRotinaComandos(context);
                  },
                  child: const Text('Encerrar corrida'),
                )
              ],
            ],
          ),
        ),
        if (statusConexaoELM != null && statusForeground != null) ...[
          if (bluetoothValido && comandosIniciados) ...[
            if (statusConexaoELM == false) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    "Dispositivo OBD desconectado",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            if (statusForeground == false) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    "Serviço em segundo plano parou",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            if (statusConexaoELM == true && statusForeground == true) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    "OBD e Serviço em segundo plano rodando",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]
          ]
        ]
      ],
    );
  }
}
