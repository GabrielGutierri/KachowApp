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
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    };

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
            {
              "object_id": "i",
              "name": "intake manifold pressure",
              "type": "Text"
            },
            {"object_id": "d", "name": "data coleta dados", "type": "Text"}
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

  static Future<void> AdicionarSubscription(String deviceName) async {}

  static Future<void> CriarEntidadeOrion(String deviceName) async {}

  static Future<bool> VerificaDispositivoExistente(
      String deviceID, String deviceName) async {
    var url = Uri.parse("http://${_ip}:4041/iot/devices/${deviceID}");
    Response response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
    if (response.statusCode > 200 && response.statusCode <= 300) {
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
