// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayModel _$PlayModelFromJson(Map<String, dynamic> json) => PlayModel(
  id: json['id'] as String,
  matchId: json['matchId'] as String,
  phase: $enumDecode(_$PlayPhaseEnumMap, json['phase']),
  minute: (json['minute'] as num).toInt(),
  action: json['action'] as String,
  outcome: json['outcome'] as String,
  points: (json['points'] as num?)?.toInt() ?? 0,
  yardas: (json['yardas'] as num?)?.toInt() ?? 0,
  down: (json['down'] as num?)?.toInt(),
  involvedPlayerIds:
      (json['involvedPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$PlayModelToJson(PlayModel instance) => <String, dynamic>{
  'id': instance.id,
  'matchId': instance.matchId,
  'phase': _$PlayPhaseEnumMap[instance.phase]!,
  'minute': instance.minute,
  'action': instance.action,
  'outcome': instance.outcome,
  'points': instance.points,
  'yardas': instance.yardas,
  'down': instance.down,
  'involvedPlayerIds': instance.involvedPlayerIds,
};

const _$PlayPhaseEnumMap = {
  PlayPhase.ataque: 'ataque',
  PlayPhase.defensa: 'defensa',
  PlayPhase.extraPoint: 'extraPoint',
};
