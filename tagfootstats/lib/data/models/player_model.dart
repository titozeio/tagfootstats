import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/player.dart';

part 'player_model.g.dart';

@JsonSerializable()
class PlayerModel extends Player {
  const PlayerModel({
    required super.id,
    required super.teamId,
    required super.firstName,
    required super.lastName,
    required super.dorsal,
    super.birthDate,
    super.email,
    super.phone,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerModelToJson(this);

  factory PlayerModel.fromEntity(Player entity) {
    return PlayerModel(
      id: entity.id,
      teamId: entity.teamId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      dorsal: entity.dorsal,
      birthDate: entity.birthDate,
      email: entity.email,
      phone: entity.phone,
    );
  }
}
