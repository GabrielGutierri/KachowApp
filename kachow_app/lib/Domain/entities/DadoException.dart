import 'package:hive/hive.dart';

part 'DadoException.g.dart'; //colocar essa linha para gerar o adapter

@HiveType(typeId: 3)
class DadoException extends HiveObject {
  @HiveField(0)
  String mensagem;
  @HiveField(1)
  String stackTrace;
  @HiveField(2)
  DateTime data;
  DadoException(
      {required this.mensagem, required this.stackTrace, required this.data});
}
