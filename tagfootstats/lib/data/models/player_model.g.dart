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
    };
