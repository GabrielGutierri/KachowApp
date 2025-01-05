import 'dart:convert';
import 'package:http/http.dart';
import 'package:kachow_app/Domain/TO/RetornoDispositivoFiwareTO.dart';
import 'package:kachow_app/Domain/TO/RetornoErroFiwareTO.dart';
import 'package:kachow_app/Domain/entities/IdentificacaoVeiculo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Fiwareservice {
  static final String ip = "46.17.108.131";

  Future<void> SalvarEntidadeVeiculo(IdentificacaoVeiculo veiculo) async {
    String deviceID = veiculo.placa;
    String deviceName = "urn:ngsi-ld:${veiculo.nome}:${veiculo.placa}";

    await ProvisionarDispositivo(deviceID, deviceName);
    await CriarEntidadeOrion(deviceName);
    await AdicionarSubscription(deviceName);
    await CriarEntidadeOrion(deviceName);
    await AdicionarSubscriptionException(deviceName);
    await CriarEntidadeException(deviceName);
    await ArmazenarValoresCarro(deviceID, deviceName);
  }

  Future<void> ProvisionarDispositivo(
      String deviceID, String deviceName) async {
    //enviar um post para a url http://{{url}}:4041/iot/devices
    var urlDevice = Uri.parse("http://$ip:4041/iot/devices");

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
            {"object_id": "d", "name": "dataColetaDados", "type": "Text"},
            {"object_id": "ic", "name": "idCorrida", "type": "float"}
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
    var urlSubscription = Uri.parse("http://$ip:1026/v2/subscriptions/");
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
            "dataColetaDados",
            "idCorrida"
          ]
        }
      },
      "notification": {
        "http": {"url": "http://$ip:8666/notify"},
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
          "idCorrida"
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
    var urlOrion = Uri.parse("http://$ip:1026/v2/entities");
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
      "dataColetaDados": {"type": "Text", "value": "0"},
      "idCorrida": {"type": "float", "value": "0"}
    };

    await http.post(urlOrion, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
  }

  Future<void> CriarEntidadeException(String deviceName) async {
    var urlOrion = Uri.parse("http://$ip:1026/v2/entities");
    var deviceException = deviceName + "Exception";
    Map<String, dynamic> body = {
      "id": deviceException,
      "type": "Exception",
      "mensagem": {"type": "Text", "value": ""},
      "stackTrace": {"type": "Text", "value": ""},
      "data": {"type": "Text", "value": ""}
    };

    await http.post(urlOrion, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
  }

  Future<void> AdicionarSubscriptionException(String deviceName) async {
    var urlSubscription = Uri.parse("http://$ip:1026/v2/subscriptions/");
    var deviceException = deviceName + "Exception";
    var body = {
      "description": "$deviceName Exceptions", // Descrição da notificação
      "subject": {
        "entities": [
          {"id": deviceException, "type": "Exception"}
        ],
        "conditions": {
          "attrs": ["mensagem"]
        }
      },
      "notification": {
        "http": {"url": "http://$ip:8666/notify"},
        "attrs": ["mensagem"],
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

  Future<bool> VerificaDispositivoExistente(
      String deviceID, String deviceName) async {
    var url = Uri.parse("http://$ip:1026/v2/entities/$deviceName");
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
}
