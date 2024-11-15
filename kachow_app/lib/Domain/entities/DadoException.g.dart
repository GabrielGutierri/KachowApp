// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DadoException.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DadoExceptionAdapter extends TypeAdapter<DadoException> {
  @override
  final int typeId = 3;

  @override
  DadoException read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DadoException(
      mensagem: fields[0] as String,
      stackTrace: fields[1] as String,
      data: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DadoException obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.mensagem)
      ..writeByte(1)
      ..write(obj.stackTrace)
      ..writeByte(2)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DadoExceptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
