class TrataMensagemOBD {
  static String TrataMensagemVelocidade(String mensagem) {
    try {
      mensagem = mensagem.trim().replaceAll(RegExp(r'41 0D'), '');
      mensagem = mensagem.trim().replaceAll(RegExp(r'01 0D'), '');

      RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
      Iterable<Match> matches = regExp.allMatches(mensagem.trim());

      // Mapeia os resultados e retorna uma lista de strings
      List<String> velocidades =
          matches.map((match) => match.group(0)!).toList();
      int speedInKmh = int.parse(velocidades[0].trim(), radix: 16);
      return speedInKmh.toString();
    } catch (e) {
      return "Erro tratativa velocidade - Resposta OBD: $mensagem";
    }
  }

  static String TrataMensagemRPM(String mensagem) {
    try {
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
    } catch (e) {
      return "Erro tratativa RPM - Resposta OBD: $mensagem";
    }
  }

  static String TrataMensagemIntakePressure(String mensagem) {
    try {
      mensagem = mensagem.trim().replaceAll(RegExp(r'01 0B'), '');
      mensagem = mensagem.trim().replaceAll(RegExp(r'41 0B'), '');
      RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
      Iterable<Match> matches = regExp.allMatches(mensagem.trim());
      List<String> intakes = matches.map((match) => match.group(0)!).toList();

      int kpa = int.parse(intakes[0].trim(), radix: 16);
      return kpa.toString();
    } catch (e) {
      return "Erro tratativa Intake Pressure- Resposta OBD: $mensagem";
    }
  }

  static String TrataMensagemIntakeTemperature(String mensagem) {
    try {
      mensagem = mensagem.trim().replaceAll(RegExp(r'01 0F'), '');
      mensagem = mensagem.trim().replaceAll(RegExp(r'41 0F'), '');
      RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
      Iterable<Match> matches = regExp.allMatches(mensagem.trim());
      List<String> intakes = matches.map((match) => match.group(0)!).toList();

      int kpa = int.parse(intakes[0].trim(), radix: 16) - 40;
      return kpa.toString();
    } catch (e) {
      return "Erro tratativa Intake Temperature - Resposta OBD: $mensagem";
    }
  }

  static String TrataMensagemEngineLoad(String mensagem) {
    try {
      mensagem = mensagem.trim().replaceAll(RegExp(r'01 04'), '');
      mensagem = mensagem.trim().replaceAll(RegExp(r'41 04'), '');
      RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
      Iterable<Match> matches = regExp.allMatches(mensagem.trim());
      List<String> loads = matches.map((match) => match.group(0)!).toList();

      double engineLoad = int.parse(loads[0].trim(), radix: 16) * 100 / 255;
      return engineLoad.toString();
    } catch (e) {
      return "Erro tratativa Engine Load - Resposta OBD: $mensagem";
    }
  }

  static String TrataMensagemThrottlePosition(String mensagem) {
    try {
      mensagem = mensagem.trim().replaceAll(RegExp(r'01 11'), '');
      mensagem = mensagem.trim().replaceAll(RegExp(r'41 11'), '');
      RegExp regExp = RegExp(r'\b[0-9A-F]{2}\b');
      Iterable<Match> matches = regExp.allMatches(mensagem.trim());
      List<String> loads = matches.map((match) => match.group(0)!).toList();

      double engineLoad = int.parse(loads[0].trim(), radix: 16) * 100 / 255;
      return engineLoad.toString();
    } catch (e) {
      return "Erro tratativa Throttle Position - Resposta OBD: $mensagem";
    }
  }
}
