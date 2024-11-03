import 'package:kachow_app/Domain/entities/DadoAcelerometro.dart';
import 'package:kachow_app/Domain/entities/DadoGeolocation.dart';
import 'package:kachow_app/Domain/entities/DadoOBD.dart';

class DadoFiware {
  DadoOBD dadoOBD;
  DadoGeolocation dadoGeolocation;
  DadoAcelerometro dadoAcelerometro;

  DadoFiware(
      {required this.dadoOBD,
      required this.dadoGeolocation,
      required this.dadoAcelerometro});
}
