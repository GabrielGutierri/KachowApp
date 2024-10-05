// Background task identifier
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HttpService {
  static List<String> respostas = [];
  String ipFiware = "46.17.108.131";
  int orionPort = 1026;

  Future<void> checkListAndPublish() async {
    Map<String, dynamic> body = {
      "velocidade": {"type": "float", "value": 0},
      "rpm": {"type": "float", "value": 0},
      "latitude": {"type": "text", "value": ""},
      "longitude": {"type": "text", "value": ""},
      "acelerometro": {"type": "text", "value": ""}
    };
    for (var message in respostas) {
      if (message.contains("01 0D")) {
        body["velocidade"]["value"] = TrataMensagemVelocidade(message.trim());
      }

      if (message.contains("01 0C")) {
        body["rpm"]["value"] = TrataMensagemRPM(message.trim());
      }
      if (message.contains("LAT")) {
        body["latitude"]["value"] = message.replaceAll("LAT", "").trim();
      }
      if (message.contains("LON")) {
        body["longitude"]["value"] = message.replaceAll("LON", "").trim();
      }
      if (isValidDateTimeFormat(message)) {
        body["dataColetaDados"]["value"] = message;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceName = prefs.getString('deviceName') ?? "";
    if (deviceName != "") {
      String urlUpdate =
          'http://$ipFiware:$orionPort/v2/entities/$deviceName/attrs';
      var url = Uri.parse(urlUpdate);
      var response = await http.post(url, body: json.encode(body), headers: {
        "Content-Type": "application/json",
        "fiware-service": "smart",
        "fiware-servicepath": "/"
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw new Exception();
      }
    } else {
      throw new Exception();
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

  String TrataMensagemIntake(String mensagem) {
    mensagem = mensagem.trim().replaceAll(RegExp(r'01 0B'), '');
    mensagem = mensagem.trim().replaceAll(RegExp(r'41 0B'), '');
    RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
    Iterable<Match> matches = regExp.allMatches(mensagem.trim());
    List<String> intakes = matches.map((match) => match.group(0)!).toList();

    int kpa = int.parse(intakes[0].trim(), radix: 16);
    return kpa.toString();
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
