import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tournament.dart';

part 'tournament_model.g.dart';

@JsonSerializable()
class TournamentModel extends Tournament {
  const TournamentModel({
    required super.id,
    required super.name,
    required super.startDate,
    required super.endDate,
    required super.type,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentModelToJson(this);

  factory TournamentModel.fromEntity(Tournament entity) {
    return TournamentModel(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      type: entity.type,
    );
  }
}
