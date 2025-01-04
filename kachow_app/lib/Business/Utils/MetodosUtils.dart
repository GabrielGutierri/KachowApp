import 'dart:io';

class Metodosutils {
  static Future<bool> VerificaConexaoInternet() async {
    final result = await InternetAddress.lookup('google.com');
    //se nao tiver net, ele retorna uma exceção
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  }
}
