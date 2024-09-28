import 'package:geolocator/geolocator.dart';

class GeolocationService {
  // Método assíncrono que retorna uma string com latitude e longitude concatenadas
  Future<String> TrataMensagemGeolocalizacao() async {
    print('TrataMensagemGeolocalizacao');
    String latitudeLongitude = 'Localização não disponível';

    try {
      // Aguardando a obtenção da geolocalização
      Position position = await _getGeoLocation();
      print('position - > ' + latitudeLongitude);
      // Concatenando latitude e longitude separadas por ;
      latitudeLongitude = "${position.latitude};${position.longitude}";
    } catch (e) {
      // Tratamento de erros (ex: falha ao obter localização)
      print('Erro ao obter a localização: $e');
    }

    print('latitudeLongitude - > ' + latitudeLongitude);
    // Retornando a string com latitude e longitude
    return latitudeLongitude;
  }

  // Método auxiliar para obter a localização
  Future<Position> _getGeoLocation() async {
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
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
