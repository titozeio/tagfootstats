// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => PlayerModel(
  id: json['id'] as String,
  teamId: json['teamId'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  dorsal: (json['dorsal'] as num).toInt(),
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  position:
      $enumDecodeNullable(_$PlayerPositionEnumMap, json['position']) ??
      PlayerPosition.both,
  photoUrl: json['photoUrl'] as String?,
);

Map<String, dynamic> _$PlayerModelToJson(PlayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dorsal': instance.dorsal,
      'birthDate': instance.birthDate?.toIso8601String(),
      'email': instance.email,
      'phone': instance.phone,
      'position': _$PlayerPositionEnumMap[instance.position]!,
      'photoUrl': instance.photoUrl,
    };

const _$PlayerPositionEnumMap = {
  PlayerPosition.offense: 'offense',
  PlayerPosition.defense: 'defense',
  PlayerPosition.both: 'both',
};
