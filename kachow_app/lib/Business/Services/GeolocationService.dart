import 'dart:async';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:geolocator/geolocator.dart';

class GeolocationService {
  double _aceleracaoX = 0.0;
  double _aceleracaoY = 0.0; // Aceleração longitudinal
  double _aceleracaoZ = 0.0;

  double _giroscopioX = 0.0;
  double _giroscopioY = 0.0;
  double _giroscopioZ = 0.0;

  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;

  GeolocationService() {
    // Inicializar os sensores
    _initializeSensors();
  }

  // Método para inicializar e escutar os eventos do acelerômetro e giroscópio
  Future<void> _initializeSensors() async {
    bool hasAccel = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);
    bool hasGyro = await SensorManager().isSensorAvailable(Sensors.GYROSCOPE);

    if (hasAccel) {
      final accelerometerStream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: const Duration(milliseconds: 100),
      );

      _accelerometerSubscription = accelerometerStream.listen((event) {
        final data = event.data;
        _aceleracaoX = data[0];
        _aceleracaoY = data[1]; // Assumindo o eixo Y como aceleração longitudinal
        _aceleracaoZ = data[2];
      });
    }

    if (hasGyro) {
      final gyroscopeStream = await SensorManager().sensorUpdates(
        sensorId: Sensors.GYROSCOPE,
        interval: const Duration(milliseconds: 100),
      );

      _gyroscopeSubscription = gyroscopeStream.listen((event) {
        final data = event.data;
        _giroscopioX = data[0];
        _giroscopioY = data[1];
        _giroscopioZ = data[2];
      });
    }
  }

  // Método para calcular a aceleração nos eixos X, Y, Z e retornar os três valores
  Future<List<double>> calculaAceleracaoSensor() async {
    try {
      // Imprimir os valores de aceleração nos eixos X, Y e Z
      print('Aceleração eixo X: $_aceleracaoX');
      print('Aceleração eixo Y (longitudinal): $_aceleracaoY');
      print('Aceleração eixo Z: $_aceleracaoZ');

      // Retornar os três valores de aceleração
      return [_aceleracaoX, _aceleracaoY, _aceleracaoZ];
    } catch (e) {
      print('Erro ao calcular a aceleração: $e');
      return [0.0, 0.0, 0.0]; // Valor padrão no caso de erro
    }
  }

  // Método para obter o valor do giroscópio e devolver os ângulos de Roll, Pitch e Yaw
  Future<List<double>> calcularOrientacao() async {
    try {
      // Pitch: inclinação para frente/trás
      double pitch = atan2(_aceleracaoY, sqrt(_aceleracaoX * _aceleracaoX + _aceleracaoZ * _aceleracaoZ)) * (180 / pi);

      // Roll: inclinação para os lados
      double roll = atan2(_aceleracaoX, sqrt(_aceleracaoY * _aceleracaoY + _aceleracaoZ * _aceleracaoZ)) * (180 / pi);

      // Yaw (rotação no plano horizontal), derivado do giroscópio
      double yaw = _giroscopioZ * (180 / pi); // Em graus por segundo

      print('Roll calculado: $roll');
      print('Pitch calculado: $pitch');
      print('Yaw calculado: $yaw');

      // Retornar os três ângulos
      return [roll, pitch, yaw];
    } catch (e) {
      print('Erro ao calcular os ângulos: $e');
      return [0.0, 0.0, 0.0]; // Valor padrão no caso de erro
    }
  }

  // Método para obter a geolocalização e retornar as coordenadas no formato GeoJSON (longitude, latitude)
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Método para cancelar as assinaturas dos sensores quando não forem mais necessários
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
  }
}
