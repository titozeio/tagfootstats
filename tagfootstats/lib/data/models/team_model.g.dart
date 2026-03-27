// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamModel _$TeamModelFromJson(Map<String, dynamic> json) => TeamModel(
  id: json['id'] as String,
  name: json['name'] as String,
  shortName: json['shortName'] as String?,
  logoUrl: json['logoUrl'] as String?,
  isOwnTeam: json['isOwnTeam'] as bool? ?? false,
);

Map<String, dynamic> _$TeamModelToJson(TeamModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'shortName': instance.shortName,
  'logoUrl': instance.logoUrl,
  'isOwnTeam': instance.isOwnTeam,
};
