import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HttpService {
  static List<String> respostas = [];
  String ipFiware = "46.17.108.131";
  int orionPort = 1026;
  var counter = 0;
  Future<void> testarHTTP() async {
    Map<String, dynamic> body = {
      'velocidade': {'type': 'float', 'value': counter++},
      'rpm': {'type': 'float', 'value': counter++},
      "pressure": {"type": "float", "value": counter++},
      "temperature": {"type": "float", "value": counter++},
      "engineload": {"type": "float", "value": counter++},
      'location': {
        'type': 'geo:json',
        'value': {
          'type': 'Point',
          'coordinates': [0.0, 0.0] // Coordenadas padrão
        }
      },
      'acelerometroEixoX': {'type': 'float', 'value': 0.0},
      'acelerometroEixoY': {'type': 'float', 'value': 0.0},
      'acelerometroEixoZ': {'type': 'float', 'value': 0.0},
      'giroscopioRow': {'type': 'float', 'value': 0.0},
      'giroscopioPitch': {'type': 'float', 'value': 0.0},
      'giroscopioYaw': {'type': 'float', 'value': 0.0},

      'dataColetaDados': {'type': 'text', 'value': ''}
    };
    String urlUpdate =
        'http://$ipFiware:$orionPort/v2/entities/urn:ngsi-ld:carro:009/attrs';
    var url = Uri.parse(urlUpdate);

    var objetoJson = json.encode(body);
    var resposta = await http.post(url, body: objetoJson, headers: {
      "Content-Type": "application/json",
      "fiware-service": "smart",
      "fiware-servicepath": "/"
    });
    print(resposta);
  }

  Future<void> checkListAndPublish() async {
    Map<String, dynamic> body = {
      "velocidade": {"type": "float", "value": 0},
      "rpm": {"type": "float", "value": 0},
      "pressure": {"type": "float", "value": 0},
      "temperature": {"type": "float", "value": 0},
      "engineload": {"type": "float", "value": 0},
      "location": {
        "type": "geo:json",
        "value": {
          "type": "Point",
          "coordinates": [0.0, 0.0] // Coordenadas padrão
        }
      },
      'acelerometroEixoX': {'type': 'float', 'value': 0.0},
      'acelerometroEixoY': {'type': 'float', 'value': 0.0},
      'acelerometroEixoZ': {'type': 'float', 'value': 0.0},
      'giroscopioRow': {'type': 'float', 'value': 0.0},
      'giroscopioPitch': {'type': 'float', 'value': 0.0},
      'giroscopioYaw': {'type': 'float', 'value': 0.0},
      "dataColetaDados": {"type": "text", "value": ""}
    };

    for (var message in respostas) {
      if (message.contains("41 0D")) {
        body["velocidade"]["value"] = TrataMensagemVelocidade(message.trim());
      } else if (message.contains("41 0C")) {
        body["rpm"]["value"] = TrataMensagemRPM(message.trim());
      } else if (message.contains("41 0B")) {
        body["pressure"]["value"] = TrataMensagemIntakePressure(message.trim());
      } else if (message.contains("41 0F")) {
        body["temperature"]["value"] = TrataMensagemIntakeTemperature(message.trim());
      } else if (message.contains("41 04")) {
        body["engineload"]["value"] = TrataMensagemEngineLoad(message.trim());
      } else if (message.contains("GEO")) {
        // Remove "GEO" e separa a string com base no ";"
        List<String> coordenadas =
            message.replaceAll("GEO", "").trim().split(";");

        // Converte longitude e latitude de string para double
        double longitude = double.parse(coordenadas[0]);
        double latitude = double.parse(coordenadas[1]);

        // Atualiza as coordenadas no body
        body["location"]["value"]["coordinates"] = [longitude, latitude];
      } else if (message.contains("ACE_X")) {
        body["acelerometroEixoX"]["value"] =
            double.parse(message.replaceAll("ACE_X", "").trim());
      }else if (message.contains("ACE_Y")) {
        body["acelerometroEixoY"]["value"] =
            double.parse(message.replaceAll("ACE_Y", "").trim());
      }else if (message.contains("ACE_Z")) {
        body["acelerometroEixoZ"]["value"] =
            double.parse(message.replaceAll("ACE_Z", "").trim());
      } else if (message.contains("GIR_R")) {
        body["giroscopioRow"]["value"] =
            double.parse(message.replaceAll("GIR_R", "").trim());
      }else if (message.contains("GIR_P")) {
        body["giroscopioPitch"]["value"] =
            double.parse(message.replaceAll("GIR_P", "").trim());
      }else if (message.contains("GIR_Y")) {
        body["giroscopioYaw"]["value"] =
            double.parse(message.replaceAll("GIR_Y", "").trim());
      } else if (isValidDateTimeFormat(message)) {
        body["dataColetaDados"]["value"] = message;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceName = prefs.getString('deviceName') ?? "";
    if (deviceName != "") {
      String urlUpdate =
          'http://$ipFiware:$orionPort/v2/entities/$deviceName/attrs';
      var url = Uri.parse(urlUpdate);

      await http.post(url, body: json.encode(body), headers: {
        "Content-Type": "application/json",
        "fiware-service": "smart",
        "fiware-servicepath": "/"
      });
    }
  }

  String TrataMensagemVelocidade(String mensagem) {
    mensagem = mensagem.trim().replaceAll(RegExp(r'41 0D'), '');
    mensagem = mensagem.trim().replaceAll(RegExp(r'01 0D'), '');

    RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
    Iterable<Match> matches = regExp.allMatches(mensagem.trim());

    // Mapeia os resultados e retorna uma lista de strings
    List<String> velocidades = matches.map((match) => match.group(0)!).toList();
    int speedInKmh = int.parse(velocidades[0].trim(), radix: 16);
    return speedInKmh.toString();
  }

  String TrataMensagemRPM(String mensagem) {
    mensagem = mensagem.trim().replaceAll(RegExp(r'01 0C'), '');
    mensagem = mensagem.trim().replaceAll(RegExp(r'41 0C'), '');

    RegExp regExp = RegExp(r'\b[0-9A-F]{2} [0-9A-F]{2}\b');
    Iterable<Match> matches = regExp.allMatches(mensagem.trim());

    List<String> rpms = matches.map((match) => match.group(0)!).toList();

    List<String> bytes = rpms[0].trim().split(' ');
    int primeiroByte = int.parse(bytes[0], radix: 16);
    int segundoByte = int.parse(bytes[1], radix: 16);

    double rpm = ((primeiroByte * 256) + segundoByte) / 4;
    return rpm.toString();
  }

  String TrataMensagemIntakePressure(String mensagem) {
    mensagem = mensagem.trim().replaceAll(RegExp(r'01 0B'), '');
    mensagem = mensagem.trim().replaceAll(RegExp(r'41 0B'), '');
    RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
    Iterable<Match> matches = regExp.allMatches(mensagem.trim());
    List<String> intakes = matches.map((match) => match.group(0)!).toList();

    int kpa = int.parse(intakes[0].trim(), radix: 16);
    return kpa.toString();
  }

  String TrataMensagemIntakeTemperature(String mensagem) {
    mensagem = mensagem.trim().replaceAll(RegExp(r'01 0F'), '');
    mensagem = mensagem.trim().replaceAll(RegExp(r'41 0F'), '');
    RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
    Iterable<Match> matches = regExp.allMatches(mensagem.trim());
    List<String> intakes = matches.map((match) => match.group(0)!).toList();

    int kpa = int.parse(intakes[0].trim(), radix: 16) - 40;
    return kpa.toString();
  }

  String TrataMensagemEngineLoad(String mensagem) {
    mensagem = mensagem.trim().replaceAll(RegExp(r'01 04'), '');
    mensagem = mensagem.trim().replaceAll(RegExp(r'41 04'), '');
    RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
    Iterable<Match> matches = regExp.allMatches(mensagem.trim());
    List<String> loads = matches.map((match) => match.group(0)!).toList();

    double engineLoad = int.parse(loads[0].trim(), radix: 16) * 100 / 255;
    return engineLoad.toString();
  }

  bool isValidDateTimeFormat(String input) {
    try {
      DateTime.parse(input); // Tenta fazer o parse da string para DateTime
      return true; // Se bem-sucedido, retorna true
    } catch (e) {
      return false; // Se falhar, não é um formato de DateTime válido
    }
  }
}
