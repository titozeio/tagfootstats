import 'package:equatable/equatable.dart';

enum TournamentType { liga, copa }

class Tournament extends Equatable {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final TournamentType type;
  final List<String> teamIds;

  const Tournament({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.teamIds = const [],
  });

  @override
  List<Object?> get props => [id, name, startDate, endDate, type, teamIds];
}
