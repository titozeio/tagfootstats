import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/match.dart';

part 'match_model.g.dart';

@JsonSerializable()
class MatchModel extends Match {
  const MatchModel({
    required super.id,
    required super.tournamentId,
    required super.opponentId,
    required super.dateTime,
    required super.locationType,
    super.matchday,
    super.phase,
    super.homeScore = 0,
    super.awayScore = 0,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$MatchModelToJson(this);

  factory MatchModel.fromEntity(Match entity) {
    return MatchModel(
      id: entity.id,
      tournamentId: entity.tournamentId,
      opponentId: entity.opponentId,
      dateTime: entity.dateTime,
      locationType: entity.locationType,
      matchday: entity.matchday,
      phase: entity.phase,
      homeScore: entity.homeScore,
      awayScore: entity.awayScore,
    );
  }
}
