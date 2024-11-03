// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DadoAcelerometro.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DadoAcelerometroAdapter extends TypeAdapter<DadoAcelerometro> {
  @override
  final int typeId = 1;

  @override
  DadoAcelerometro read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DadoAcelerometro(
      dataColetaDados: fields[0] as DateTime,
      aceleracaoX: fields[1] as double,
      aceleracaoY: fields[2] as double,
      aceleracaoZ: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DadoAcelerometro obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dataColetaDados)
      ..writeByte(1)
      ..write(obj.aceleracaoX)
      ..writeByte(2)
      ..write(obj.aceleracaoY)
      ..writeByte(3)
      ..write(obj.aceleracaoZ);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DadoAcelerometroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
