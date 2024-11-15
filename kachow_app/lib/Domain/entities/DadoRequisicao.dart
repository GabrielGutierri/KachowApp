import 'package:hive/hive.dart';

part 'DadoRequisicao.g.dart';

@HiveType(typeId: 2)
class DadoRequisicao extends HiveObject {
  @HiveField(0)
  late int status;
  @HiveField(1)
  late String requisicao;
}
