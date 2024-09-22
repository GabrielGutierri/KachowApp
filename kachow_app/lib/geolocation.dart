import 'package:geolocator/geolocator.dart';

class Geolocation {
  // Método síncrono que retorna uma string com latitude e longitude concatenadas
  static String TrataMensagemGeolocalizacao() {
    String latitudeLongitude = 'Localização não disponível';

    // Lógica assíncrona para obter a geolocalização
    _getGeoLocation().then((position) {
      latitudeLongitude = "${position.latitude};${position.longitude}";
    });

    print("Latitude e Longitude: $latitudeLongitude");

    // Retorna a string inicialmente com "Localização não disponível" até o Future ser resolvido
    return latitudeLongitude;
  }

  // Método auxiliar para obter a localização
  static Future<Position> _getGeoLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar se o serviço de localização está ativado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização está desativado.');
    }

    // Verificar e solicitar permissões de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permissão de localização negada permanentemente, não é possível solicitar.');
    }

    // Obter a posição atual (latitude e longitude)
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
