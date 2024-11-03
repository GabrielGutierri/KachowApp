// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DadoOBD.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DadoOBDAdapter extends TypeAdapter<DadoOBD> {
  @override
  final int typeId = 0;

  @override
  DadoOBD read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DadoOBD()
      ..dataColetaDados = fields[0] as DateTime
      ..velocidade = fields[1] as String
      ..rpm = fields[2] as String
      ..pressaoColetorAdmissao = fields[3] as String
      ..tempArAdmissao = fields[4] as String
      ..engineLoad = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, DadoOBD obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.engineLoad);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DadoOBDAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
