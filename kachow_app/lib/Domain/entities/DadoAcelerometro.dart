import 'package:hive/hive.dart';

part 'DadoAcelerometro.g.dart';

@HiveType(typeId: 1)
class DadoAcelerometro extends HiveObject {
  @HiveField(0)
  DateTime dataColetaDados;
  @HiveField(1)
  double aceleracaoX;
  @HiveField(2)
  double aceleracaoY;
  @HiveField(3)
  double aceleracaoZ;

  DadoAcelerometro(
      {required this.dataColetaDados,
      required this.aceleracaoX,
      required this.aceleracaoY,
      required this.aceleracaoZ});
}
