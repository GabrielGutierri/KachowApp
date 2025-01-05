import 'package:hive/hive.dart';

part 'DadoCarro.g.dart';

@HiveType(typeId: 0)
class DadoCarro extends HiveObject {
  @HiveField(0)
  late DateTime dataColetaDados;
  @HiveField(1)
  late String velocidade;
  @HiveField(2)
  late String rpm;
  @HiveField(3)
  late String pressaoColetorAdmissao;
  @HiveField(4)
  late String tempArAdmissao;
  @HiveField(5)
  late String engineLoad;
  @HiveField(6)
  late String throttlePosition;
  @HiveField(7)
  late double aceleracaoX;
  @HiveField(8)
  late double aceleracaoY;
  @HiveField(9)
  late double aceleracaoZ;
  @HiveField(10)
  late double latitude;
  @HiveField(11)
  late double longitude;
  @HiveField(12)
  late double giroscopioX;
  @HiveField(13)
  late double giroscopioY;
  @HiveField(14)
  late double giroscopioZ;
  @HiveField(15)
  late int idCorrida;
}
