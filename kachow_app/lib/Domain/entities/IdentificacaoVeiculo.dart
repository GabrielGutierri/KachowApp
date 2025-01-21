import 'package:hive/hive.dart';

part 'IdentificacaoVeiculo.g.dart';

@HiveType(typeId: 4)
class IdentificacaoVeiculo extends HiveObject {
  @HiveField(0)
  String nome;
  @HiveField(1)
  String placa;

  IdentificacaoVeiculo({required this.nome, required this.placa});
}
