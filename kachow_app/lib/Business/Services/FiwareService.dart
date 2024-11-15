import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:kachow_app/Business/Utils/TrataMensagemOBD.dart';
import 'package:kachow_app/Business/Utils/TrataMensagemSensores.dart';
import 'package:kachow_app/Domain/TO/RetornoDispositivoFiwareTO.dart';
import 'package:kachow_app/Domain/TO/RetornoErroFiwareTO.dart';
import 'package:kachow_app/Domain/entities/DadoCarro.dart';
import 'package:kachow_app/Domain/entities/DadoException.dart';
import 'package:kachow_app/Domain/entities/IdentificacaoVeiculo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

class Fiwareservice {
  final String _ip = "46.17.108.131";

  Future<void> SalvarEntidadeVeiculo(IdentificacaoVeiculo veiculo) async {
    String deviceID = veiculo.placa;
    String deviceName = "urn:ngsi-ld:${veiculo.nome}:${veiculo.placa}";

    await ProvisionarDispositivo(deviceID, deviceName);
    await CriarEntidadeOrion(deviceName);
    await AdicionarSubscription(deviceName);
    await CriarEntidadeOrion(deviceName);
    await ArmazenarValoresCarro(deviceID, deviceName);
  }

  Future<void> ProvisionarDispositivo(
      String deviceID, String deviceName) async {
    //enviar um post para a url http://{{url}}:4041/iot/devices
    var urlDevice = Uri.parse("http://$_ip:4041/iot/devices");

    var body = {
      "devices": [
        {
          "device_id": deviceID,
          "entity_name": deviceName,
          "entity_type": "Carro",
          "protocol": "PDI-IoTA-UltraLight",
          "transport": "HTTP",
          "attributes": [
            {"object_id": "v", "name": "velocidade", "type": "float"},
            {"object_id": "r", "name": "rpm", "type": "float"},
            {"object_id": "p", "name": "pressure", "type": "float"},
            {"object_id": "t", "name": "temperature", "type": "float"},
            {"object_id": "e", "name": "engineload", "type": "float"},
            {"object_id": "tp", "name": "throttlePosition", "type": "float"},
            {
              "object_id": "g",
              "name": "location",
              "type": "geo:json",
              "value": {
                "type": "Point",
                "coordinates": [0, 0] // Placeholder para coordenadas reais
              }
            },
            {"object_id": "ax", "name": "acelerometroEixoX", "type": "float"},
            {"object_id": "ay", "name": "acelerometroEixoY", "type": "float"},
            {"object_id": "az", "name": "acelerometroEixoZ", "type": "float"},
            {"object_id": "gr", "name": "giroscopioRow", "type": "float"},
            {"object_id": "gp", "name": "giroscopioPitch", "type": "float"},
            {"object_id": "gy", "name": "giroscopioYaw", "type": "float"},
            {"object_id": "d", "name": "dataColetaDados", "type": "Text"}
          ]
        }
      ]
    };

    await http.post(urlDevice, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
  }

  Future<void> AdicionarSubscription(String deviceName) async {
    var urlSubscription = Uri.parse("http://$_ip:1026/v2/subscriptions/");
    var body = {
      "description":
          "Notificar STH Comet de mudanças em $deviceName", // Descrição da notificação
      "subject": {
        "entities": [
          {"id": deviceName, "type": "Carro"}
        ],
        "conditions": {
          "attrs": [
            "velocidade",
            "rpm",
            "pressure",
            "temperature",
            "engineload",
            "throttlePosition",
            "location",
            "acelerometroEixoX",
            "acelerometroEixoY",
            "acelerometroEixoZ",
            "giroscopioRow",
            "giroscopioPitch",
            "giroscopioYaw",
            "dataColetaDados"
          ]
        }
      },
      "notification": {
        "http": {"url": "http://$_ip:8666/notify"},
        "attrs": [
          "velocidade",
          "rpm",
          "pressure",
          "temperature",
          "engineload",
          "location",
          "throttlePosition",
          "acelerometroEixoX",
          "acelerometroEixoY",
          "acelerometroEixoZ",
          "giroscopioRow",
          "giroscopioPitch",
          "giroscopioYaw",
          "dataColetaDados",
        ],
        "attrsFormat":
            "legacy" // Formato dos atributos a ser notificado (legado)
      }
    };

    await http.post(urlSubscription, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
  }

  Future<void> CriarEntidadeOrion(String deviceName) async {
    var urlOrion = Uri.parse("http://$_ip:1026/v2/entities");
    Map<String, dynamic> body = {
      "id": deviceName, //substituir carro pelo entity_name do passo anterior
      "type": "Carro",
      "velocidade": {"type": "float", "value": 0},
      "rpm": {"type": "float", "value": 0},
      "pressure": {"type": "float", "value": 0},
      "temperature": {"type": "float", "value": 0},
      "engineload": {"type": "float", "value": 0},
      "throttlePosition": {"type": "float", "value": 0},
      "location": {
        "type": "geo:json",
        "value": {
          "type": "Point",
          "coordinates": [0, 0] // Placeholder para coordenadas reais
        }
      },
      'acelerometroEixoX': {'type': 'float', 'value': 0},
      'acelerometroEixoY': {'type': 'float', 'value': 0},
      'acelerometroEixoZ': {'type': 'float', 'value': 0},
      'giroscopioRow': {'type': 'float', 'value': 0},
      'giroscopioPitch': {'type': 'float', 'value': 0},
      'giroscopioYaw': {'type': 'float', 'value': 0},
      "dataColetaDados": {"type": "Text", "value": "0"}
    };

    await http.post(urlOrion, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
  }

  Future<bool> VerificaDispositivoExistente(
      String deviceID, String deviceName) async {
    var url = Uri.parse("http://$_ip:1026/v2/entities/$deviceName");
    Response response = await http.get(url,
        headers: {"fiware-service": "smart", "fiware-servicepath": "/"});
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (respostaGetValida(response, deviceName)) {
        await ArmazenarValoresCarro(deviceID, deviceName);
        return true;
      }
      throw new Exception();
    } else {
      if (respostaNaoExisteValida(response)) {
        return false;
      }
      throw new Exception();
    }
  }

  bool respostaGetValida(Response response, String deviceName) {
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    RetornoDispositivoFiwareTO dispositivo =
        RetornoDispositivoFiwareTO.fromJson(jsonMap);
    return dispositivo.id == deviceName && dispositivo.type == 'Carro';
  }

  bool respostaNaoExisteValida(Response response) {
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    RetornoErroFiwareTO retornoErro = RetornoErroFiwareTO.fromJson(jsonMap);

    return retornoErro.description ==
        "The requested entity has not been found. Check type and id";
  }

  Future<void> ArmazenarValoresCarro(String deviceID, String deviceName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', deviceID);
    await prefs.setString('deviceName', deviceName);
  }

  Future<void> preencheTabelaFIWARE() async {
    Box<DadoCarro> boxDados = await Hive.openBox('tbFilaDados');

    var dadosCarro = boxDados.values;

    List<DadoCarro> listaCarro = [];

    for (var dadoCarro in dadosCarro) {
      listaCarro.add(dadoCarro);
      boxDados.delete(dadoCarro.key);
    }

    await RotinaEnvioFIWARE(listaCarro);
  }

  Future<void> RotinaEnvioFIWARE(List<DadoCarro> listaGeral) async {
    try {
      String conteudo = "";
      for (var dado in listaGeral) {
        Map<String, dynamic> body = {
          "velocidade": {
            "type": "float",
            "value": TrataMensagemOBD.TrataMensagemVelocidade(dado.velocidade)
            //"value": dado.obd.velocidade
          },
          "rpm": {
            "type": "float",
            "value": TrataMensagemOBD.TrataMensagemRPM(dado.rpm)
            //"value": dado.obd.rpm
          },
          "pressure": {
            "type": "float",
            "value": TrataMensagemOBD.TrataMensagemIntakePressure(
                dado.pressaoColetorAdmissao)
            //"value": dado.obd.pressaoColetorAdmissao
          },
          "temperature": {
            "type": "float",
            "value": TrataMensagemOBD.TrataMensagemIntakeTemperature(
                dado.tempArAdmissao)
            //"value": dado.obd.tempArAdmissao
          },
          "engineload": {
            "type": "float",
            "value": TrataMensagemOBD.TrataMensagemEngineLoad(dado.engineLoad)
            //"value": dado.obd.engineLoad
          },
          "throttlePosition": {
            "type": "float",
            "value": TrataMensagemOBD.TrataMensagemThrottlePosition(
                dado.throttlePosition)
          },
          "location": {
            "type": "geo:json",
            "value": {
              "type": "Point",
              "coordinates": [
                dado.latitude,
                dado.longitude
              ] // Coordenadas padrão
            }
          },
          'acelerometroEixoX': {'type': 'float', 'value': dado.aceleracaoX},
          'acelerometroEixoY': {'type': 'float', 'value': dado.aceleracaoY},
          'acelerometroEixoZ': {'type': 'float', 'value': dado.aceleracaoZ},
          'giroscopioRow': {
            'type': 'float',
            'value': TrataMensagemSensores.CalculaGiroscopioRow(
                dado.aceleracaoX, dado.aceleracaoY, dado.aceleracaoZ)
          },
          'giroscopioPitch': {
            'type': 'float',
            'value': TrataMensagemSensores.CalculaGiroscopioPitch(
                dado.aceleracaoY, dado.aceleracaoX, dado.aceleracaoZ)
          },
          'giroscopioYaw': {
            'type': 'float',
            'value':
                TrataMensagemSensores.CalculaGiroscopioYaw(dado.giroscopioZ)
          },
          "dataColetaDados": {
            "type": "Text",
            "value": dado.dataColetaDados.toString()
          }
        };
        conteudo += jsonEncode(body) + "\n";
        //ao invés de jogar no fiware, por ora vou salvar num txt

        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // String deviceName = prefs.getString('deviceName') ?? "";
        // if (deviceName != "") {
        //   String urlUpdate = 'http://$_ip:1026/v2/entities/$deviceName/attrs';
        //   var url = Uri.parse(urlUpdate);

        //   await http.post(url, body: json.encode(body), headers: {
        //     "Content-Type": "application/json",
        //     "fiware-service": "smart",
        //     "fiware-servicepath": "/"
        //   });
        //}
      }
      conteudo += "\n--------------------- INFOS ---------------------\n";
      int tamanhoListaGeral = listaGeral.length;
      DateTime inicioColeta = listaGeral[0].dataColetaDados;
      DateTime fimColeta = listaGeral[tamanhoListaGeral - 1].dataColetaDados;
      conteudo +=
          "Tamanho listaGeral: $tamanhoListaGeral\n Inicio coleta: $inicioColeta \n Fim coleta: $fimColeta";

      Box<DadoException> boxException = await Hive.openBox('tbException');
      var dadosException = boxException.values;
      conteudo += "\n--------------------- EXCEPTIONS ---------------------\n";
      for (var ex in dadosException) {
        String message = ex.mensagem;
        String stackTrace = ex.stackTrace;
        DateTime data = ex.data;
        conteudo +=
            "DataException: $data - Mensagem: $message - Stack: $stackTrace \n";
        boxException.delete(ex.key);
      }

      var dataAtual = DateTime.now();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/dadosCorrida$dataAtual.txt');
      await file.writeAsString(conteudo);
      await Share.shareFiles([file.path], text: 'Aqui está o arquivo JSON!');
    } catch (e, stackTrace) {
      String conteudo = "";
      var boxException = await Hive.openBox<DadoException>('tbException');
      boxException.add(new DadoException(
          mensagem: e.toString(),
          stackTrace: stackTrace.toString(),
          data: DateTime.now()));

      conteudo += "\n--------------------- INFOS ---------------------\n";
      if (listaGeral.length != 0) {
        int tamanhoListaGeral = listaGeral.length;
        DateTime inicioColeta = listaGeral[0].dataColetaDados;
        DateTime fimColeta = listaGeral[tamanhoListaGeral - 1].dataColetaDados;
        conteudo +=
            "Tamanho listaGeral: $tamanhoListaGeral\n Inicio coleta: $inicioColeta \n Fim coleta: $fimColeta";
      }
      var dadosException = boxException.values;
      conteudo += "\n--------------------- EXCEPTIONS ---------------------\n";
      for (var ex in dadosException) {
        String message = ex.mensagem;
        String stackTrace = ex.stackTrace;
        DateTime data = ex.data;
        conteudo +=
            "DataException: $data - Mensagem: $message - Stack: $stackTrace \n";
        boxException.delete(ex.key);
      }
    }
  }
}
