// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DadoGeolocation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DadoGeolocationAdapter extends TypeAdapter<DadoGeolocation> {
  @override
  final int typeId = 2;

  @override
  DadoGeolocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DadoGeolocation(
      dataColetaDados: fields[0] as DateTime,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DadoGeolocation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dataColetaDados)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DadoGeolocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
