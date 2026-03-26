import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/team.dart';

part 'team_model.g.dart';

@JsonSerializable()
class TeamModel extends Team {
  const TeamModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.isOwnTeam = false,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeamModelToJson(this);

  factory TeamModel.fromEntity(Team entity) {
    return TeamModel(
      id: entity.id,
      name: entity.name,
      logoUrl: entity.logoUrl,
      isOwnTeam: entity.isOwnTeam,
    );
  }
}
