import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/play.dart';

part 'play_model.g.dart';

@JsonSerializable()
class PlayModel extends Play {
  const PlayModel({
    required super.id,
    required super.matchId,
    required super.phase,
    required super.minute,
    required super.action,
    required super.outcome,
    super.points = 0,
    super.yardas = 0,
    super.down,
    super.involvedPlayerIds = const [],
    super.opponentInvolvedPlayerIds = const [],
    super.scoringTeamId,
    super.foulType,
    super.isLossOfDown = false,
    super.isAutomaticFirstDown = false,
    super.penalizingTeamId,
    super.penalizedPlayerId,
  });

  factory PlayModel.fromJson(Map<String, dynamic> json) =>
      _$PlayModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlayModelToJson(this);

  factory PlayModel.fromEntity(Play entity) {
    return PlayModel(
      id: entity.id,
      matchId: entity.matchId,
      phase: entity.phase,
      minute: entity.minute,
      action: entity.action,
      outcome: entity.outcome,
      points: entity.points,
      yardas: entity.yardas,
      down: entity.down,
      involvedPlayerIds: entity.involvedPlayerIds,
      opponentInvolvedPlayerIds: entity.opponentInvolvedPlayerIds,
      scoringTeamId: entity.scoringTeamId,
      foulType: entity.foulType,
      isLossOfDown: entity.isLossOfDown,
      isAutomaticFirstDown: entity.isAutomaticFirstDown,
      penalizingTeamId: entity.penalizingTeamId,
      penalizedPlayerId: entity.penalizedPlayerId,
    );
  }
}
