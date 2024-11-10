// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DadoCarro.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DadoCarroAdapter extends TypeAdapter<DadoCarro> {
  @override
  final int typeId = 0;

  @override
  DadoCarro read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DadoCarro()
      ..dataColetaDados = fields[0] as DateTime
      ..velocidade = fields[1] as String
      ..rpm = fields[2] as String
      ..pressaoColetorAdmissao = fields[3] as String
      ..tempArAdmissao = fields[4] as String
      ..engineLoad = fields[5] as String
      ..throttlePosition = fields[6] as String
      ..aceleracaoX = fields[7] as double
      ..aceleracaoY = fields[8] as double
      ..aceleracaoZ = fields[9] as double
      ..latitude = fields[10] as double
      ..longitude = fields[11] as double;
  }

  @override
  void write(BinaryWriter writer, DadoCarro obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.dataColetaDados)
      ..writeByte(1)
      ..write(obj.velocidade)
      ..writeByte(2)
      ..write(obj.rpm)
      ..writeByte(3)
      ..write(obj.pressaoColetorAdmissao)
      ..writeByte(4)
      ..write(obj.tempArAdmissao)
      ..writeByte(5)
      ..write(obj.engineLoad)
      ..writeByte(6)
      ..write(obj.throttlePosition)
      ..writeByte(7)
      ..write(obj.aceleracaoX)
      ..writeByte(8)
      ..write(obj.aceleracaoY)
      ..writeByte(9)
      ..write(obj.aceleracaoZ)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DadoCarroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
