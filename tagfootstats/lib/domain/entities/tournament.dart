import 'package:equatable/equatable.dart';

enum TournamentType { liga, copa }

class Tournament extends Equatable {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final TournamentType type;

  const Tournament({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, startDate, endDate, type];
}
