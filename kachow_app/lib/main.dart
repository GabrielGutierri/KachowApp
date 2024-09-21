import 'package:flutter/material.dart';
import 'package:kachow_app/fiwareservice.dart';
import 'package:kachow_app/BluetoothScreenState.dart';
import 'package:kachow_app/models/IdentificacaoVeiculo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Identificação de veículo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IdentificacaoCarroScreen(),
    );
  }
}

class IdentificacaoCarroScreen extends StatefulWidget {
  @override
  _IdentificacaoCarroScreenState createState() =>
      _IdentificacaoCarroScreenState();
}

class _IdentificacaoCarroScreenState extends State<IdentificacaoCarroScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  String? _mensagemErro;

  Future<void> _salvarCarro(String nome, String placa) async {
    await Fiwareservice.SalvarEntidadeVeiculo(
        new IdentificacaoVeiculo(nome: nome, placa: placa));
  }

  Future<bool> _validarCarro(String nome, String placa) async {
    String deviceName = "urn:ngsi-ld:${nome}:${placa}";
    return await Fiwareservice.VerificaDispositivoExistente(placa, deviceName);
  }

  void _loginOuCadastrar() async {
    String nome = _nomeController.text;
    String placa = _placaController.text;

    if (nome.isEmpty || placa.isEmpty) {
      setState(() {
        _mensagemErro = 'Por favor, insira o nome e a placa do carro.';
      });
      return;
    }

    bool existe = await _validarCarro(nome, placa);
    if (existe) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BluetoothScreenState()),
      );
    } else {
      _salvarCarro(nome, placa);
      setState(() {});
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BluetoothScreenState()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Carro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome do carro'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _placaController,
                decoration: InputDecoration(labelText: 'Placa do carro'),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _loginOuCadastrar,
                child: Text('Entrar'),
              ),
              if (_mensagemErro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _mensagemErro!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
