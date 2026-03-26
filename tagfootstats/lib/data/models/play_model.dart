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
    super.involvedPlayerIds = const [],
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
      involvedPlayerIds: entity.involvedPlayerIds,
    );
  }
}
