import 'package:hive/hive.dart';

part 'DadoOBD.g.dart';

@HiveType(typeId: 0)
class DadoOBD extends HiveObject {
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
}
