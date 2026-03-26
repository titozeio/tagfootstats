// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentModel _$TournamentModelFromJson(Map<String, dynamic> json) =>
    TournamentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      type: $enumDecode(_$TournamentTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TournamentModelToJson(TournamentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'type': _$TournamentTypeEnumMap[instance.type]!,
    };

const _$TournamentTypeEnumMap = {
  TournamentType.liga: 'liga',
  TournamentType.copa: 'copa',
};
