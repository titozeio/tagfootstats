// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) => MatchModel(
  id: json['id'] as String,
  tournamentId: json['tournamentId'] as String,
  opponentId: json['opponentId'] as String,
  dateTime: DateTime.parse(json['dateTime'] as String),
  locationType: $enumDecode(_$LocationTypeEnumMap, json['locationType']),
  matchday: (json['matchday'] as num?)?.toInt(),
  phase: json['phase'] as String?,
  homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
  awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MatchModelToJson(MatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'opponentId': instance.opponentId,
      'dateTime': instance.dateTime.toIso8601String(),
      'locationType': _$LocationTypeEnumMap[instance.locationType]!,
      'matchday': instance.matchday,
      'phase': instance.phase,
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
    };

const _$LocationTypeEnumMap = {
  LocationType.local: 'local',
  LocationType.visitante: 'visitante',
  LocationType.neutro: 'neutro',
};
