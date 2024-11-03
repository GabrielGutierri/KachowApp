import 'package:hive/hive.dart';
part 'DadoGeolocation.g.dart';

@HiveType(typeId: 2)
class DadoGeolocation extends HiveObject {
  @HiveField(0)
  DateTime dataColetaDados;
  @HiveField(1)
  double latitude;
  @HiveField(2)
  double longitude;

  DadoGeolocation(
      {required this.dataColetaDados,
      required this.latitude,
      required this.longitude});
}
