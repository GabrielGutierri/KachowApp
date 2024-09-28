// Background task identifier
import 'package:mqtt_client/mqtt_client.dart';
import 'package:kachow_app/geolocation.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mqttservice {
  static List<String> respostas = [];
  String mqttURL = "46.17.108.131";
  int mqttPort = 1883;
  String identifier = "carro";
  String topicVelocidade = 'TEF/carro/attrs/v';
  String topicRPM = 'TEF/carro/attrs/r';
  String topicLatitude = 'TEF/carro/attrs/la';
  String topicLongitude = 'TEF/carro/attrs/lo';
  String topicDataColeta = 'TEF/carro/attrs/d';

  Future<MqttServerClient> setupMqtt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceID = prefs.getString('deviceID') ?? "carro";
    identifier.replaceFirst('carro', deviceID);

    final client = MqttServerClient.withPort(mqttURL, identifier, mqttPort);
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(identifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        topicVelocidade.replaceFirst('carro', deviceID);
        // topicIntake.replaceAll('carro', deviceID);
        topicRPM.replaceFirst('carro', deviceID);
        topicDataColeta.replaceFirst('carro', deviceID);
        topicLongitude = topicLongitude.replaceFirst('carro', deviceID);
        topicLatitude = topicLatitude.replaceFirst('carro', deviceID);
        print('Conectado ao broker MQTT');
      } else {
        print('Falha na conexão');
        client.disconnect();
      }
    } catch (e) {
      print('Erro de conexão: $e');
      client.disconnect();
    }

    return client;
  }

  void publishMqttMessage(MqttServerClient client, String message) {
    final builder = MqttClientPayloadBuilder();
    String mensagem = "";
    String topic = "";

    if (message.contains("01 0D")) {
      mensagem = TrataMensagemVelocidade(message.trim());
      topic = topicVelocidade;
    }

    if (message.contains("01 0C")) {
      mensagem = TrataMensagemRPM(message.trim());
      topic = topicRPM;
    }
    // if (message.contains("01 0B")) {
    //   mensagem = TrataMensagemIntake(message.trim());
    //   topic = topicIntake;
    // }

    if (message.contains("LAT")) {
      mensagem = message.replaceAll("LAT", "").trim();
      topic = topicLatitude;
    }
    if (message.contains("LON")) {
      mensagem = message.replaceAll("LON", "").trim();
    }
    if (isValidDateTimeFormat(message)) {
      mensagem = message;
      topic = topicDataColeta;
    }
    builder.addUTF8String(mensagem);

    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  Future<void> checkListAndPublish() async {
    // Setup MQTT
    final client = await setupMqtt();
    // Publish each message in the list
    try {
      for (var message in respostas) {
        publishMqttMessage(client, message);
      }
      // Disconnect the MQTT client
      client.disconnect();
    } catch (e) {
      client.disconnect();
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
