import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class GeolocationService {
  double _aceleracaoX = 0.0;
  double _aceleracaoY = 0.0;
  double _aceleracaoZ = 0.0;

  double _giroscopioX = 0.0;
  double _giroscopioY = 0.0;
  double _giroscopioZ = 0.0;

  GeolocationService() {
    // Escutar eventos do UserAccelerometer (sem gravidade)
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      _aceleracaoX = event.x;
      _aceleracaoY = event.y;
      _aceleracaoZ = event.z;

    });

    // Escutar eventos do giroscópio
    gyroscopeEvents.listen((GyroscopeEvent event) {
      _giroscopioX = event.x;
      _giroscopioY = event.y;
      _giroscopioZ = event.z;

    });
  }

  // Método que retorna as coordenadas no formato GeoJSON (longitude, latitude)
  Future<List<double>> TrataMensagemGeolocalizacao() async {
    try {
      Position position = await _getGeoLocation();
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      return [position.longitude, position.latitude];
    } catch (e) {
      print('Erro ao obter a localização: $e');
      return [0.0, 0.0]; // Valor padrão no caso de erro
    }
  }

  // Método auxiliar para obter a localização
  Future<Position> _getGeoLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização está desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Método para calcular a aceleração total usando o sensor do acelerômetro
  Future<double> calculaAceleracaoSensor() async {
    try {
      // Exibir valores atuais de aceleração nos eixos X, Y e Z
      print('Valor atual do eixo X: $_aceleracaoX');
      print('Valor atual do eixo Y: $_aceleracaoY');
      print('Valor atual do eixo Z: $_aceleracaoZ');

      // Calcula a magnitude da aceleração com base nos eixos X, Y e Z
      double aceleracaoTotal = (_aceleracaoX * _aceleracaoX) +
                              (_aceleracaoY * _aceleracaoY) +
                              (_aceleracaoZ * _aceleracaoZ);

      print('Soma dos quadrados das acelerações: $aceleracaoTotal');

      // Calcular a raiz quadrada para obter a aceleração total
      double aceleracaoFinal = sqrt(aceleracaoTotal);

      // Exibir o valor final da aceleração calculada
      print('Aceleração total (magnitude): $aceleracaoFinal');

      return aceleracaoFinal; // Retorna a aceleração total
    } catch (e) {
      print('Erro ao calcular a aceleração total: $e');
      return 0.0; // Valor padrão no caso de erro
    }
  }

  // Método para obter o valor do giroscópio
  Future<List<double>> obterGiroscopio() async {
    try {
      // Retornar os dados do giroscópio nos três eixos (X, Y, Z)
      return [_giroscopioX, _giroscopioY, _giroscopioZ];
    } catch (e) {
      print('Erro ao obter o giroscópio: $e');
      return [0.0, 0.0, 0.0]; // Valor padrão no caso de erro
    }
  }
}
