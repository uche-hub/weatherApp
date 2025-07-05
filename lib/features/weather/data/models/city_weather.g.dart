// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_weather.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CityWeatherAdapter extends TypeAdapter<CityWeather> {
  @override
  final int typeId = 0;

  @override
  CityWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CityWeather(
      cityName: fields[0] as String,
      temperature: fields[1] as String,
      range: fields[2] as String,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CityWeather obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cityName)
      ..writeByte(1)
      ..write(obj.temperature)
      ..writeByte(2)
      ..write(obj.range)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
