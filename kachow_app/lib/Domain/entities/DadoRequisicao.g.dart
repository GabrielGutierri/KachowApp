// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DadoRequisicao.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DadoRequisicaoAdapter extends TypeAdapter<DadoRequisicao> {
  @override
  final int typeId = 2;

  @override
  DadoRequisicao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DadoRequisicao()
      ..status = fields[0] as int
      ..requisicao = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, DadoRequisicao obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.requisicao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DadoRequisicaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
