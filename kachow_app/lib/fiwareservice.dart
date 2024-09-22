import 'dart:convert';

import 'package:http/http.dart';
import 'package:kachow_app/models/IdentificacaoVeiculo.dart';
import 'package:kachow_app/mqttservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Fiwareservice {
  static String _ip = "46.17.108.131";
  static Future<void> SalvarEntidadeVeiculo(
      IdentificacaoVeiculo veiculo) async {
    String deviceID = veiculo.placa;
    String deviceName = "urn:ngsi-ld:${veiculo.nome}:${veiculo.placa}";

    await ProvisionarDispositivo(deviceID, deviceName);
    await AdicionarSubscription(deviceName);
    await CriarEntidadeOrion(deviceName);

    await ArmazenarValoresCarro(deviceID, deviceName);
  }

  static Future<void> ProvisionarDispositivo(
      String deviceID, String deviceName) async {
    //enviar um post para a url http://{{url}}:4041/iot/devices
    var urlDevice = Uri.parse("http://${_ip}:4041/iot/devices");

    var body = {
      "devices": [
        {
          "device_id": "${deviceID}",
          "entity_name": "${deviceName}",
          "entity_type": "Carro",
          "protocol": "PDI-IoTA-UltraLight",
          "transport": "MQTT",
          "attributes": [
            {"object_id": "v", "name": "velocidade", "type": "Text"},
            {"object_id": "r", "name": "rpm", "type": "Text"},
            {"object_id": "la", "name": "latitude", "type": "Text"},
            {"object_id": "lo", "name": "longitude", "type": "Text"},
            {"object_id": "a", "name": "acelerometro", "type": "Text"},
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

  static Future<void> AdicionarSubscription(String deviceName) async {
    var urlSubscription = Uri.parse("http://${_ip}:1026/v2/subscriptions/");
    var body = {
      "description":
          "Notificar STH Comet de mudanças em ${deviceName}", // Descrição da notificação
      "subject": {
        "entities": [
          {"id": deviceName, "type": "Carro"}
        ],
        "conditions": {
          "attrs": [
            "velocidade",
            "rpm",
            "latitude",
            "longitude",
            "acelerometro",
            "dataColetaDados"
          ]
        }
      },
      "notification": {
        "http": {"url": "http://${_ip}:8666/notify"},
        "attrs": [
          "velocidade",
          "rpm",
          "latitude",
          "longitude",
          "acelerometro",
          "dataColetaDados"
        ],
        "attrsFormat":
            "legacy" // Formato dos atributos a ser notificado (legado)
      }
    };

    var jsonComet = await http.post(urlSubscription, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
  }

  static Future<void> CriarEntidadeOrion(String deviceName) async {
    var urlOrion = Uri.parse("http://${_ip}:1026/v2/entities");
    var body = {
      "id": deviceName, //substituir carro pelo entity_name do passo anterior
      "type": "Carro",
      "velocidade": {"type": "Text", "value": "0"},
      "rpm": {"type": "Text", "value": "0"},
      "latitude": {"type": "Text", "value": "0"},
      "longitude": {"type": "Text", "value": "0"},
      "acelerometro": {"type": "Text", "value": "0"},
      "dataColetaDados": {"type": "Text", "value": "0"}
    };

    await http.post(urlOrion, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
  }

  static Future<bool> VerificaDispositivoExistente(
      String deviceID, String deviceName) async {
    var url = Uri.parse("http://${_ip}:4041/iot/devices/${deviceID}");
    Response response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await ArmazenarValoresCarro(deviceID, deviceName);
      return true;
    }
    return false;
  }

  static Future<void> ArmazenarValoresCarro(
      String deviceID, String deviceName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', deviceID);
    await prefs.setString('deviceName', deviceName);
  }
}
