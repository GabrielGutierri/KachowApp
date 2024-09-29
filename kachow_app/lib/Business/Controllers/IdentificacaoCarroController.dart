import 'package:kachow_app/Business/Services/FiwareService.dart';
import 'package:kachow_app/Domain/entities/IdentificacaoVeiculo.dart';

class IdentificacaoCarroController {
  final Fiwareservice _fiwareservice;

  IdentificacaoCarroController(this._fiwareservice);

  Future<void> salvarCarro(String nome, String placa) async {
    await _fiwareservice.SalvarEntidadeVeiculo(
        IdentificacaoVeiculo(nome: nome, placa: placa));
  }

  Future<bool> validarCarro(String nome, String placa) async {
    String deviceName = "urn:ngsi-ld:$nome:$placa";
    return await _fiwareservice.VerificaDispositivoExistente(placa, deviceName);
  }
}
