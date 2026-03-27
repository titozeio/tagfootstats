import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final bool isOwnTeam;

  const Team({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.isOwnTeam = false,
  });

  @override
  List<Object?> get props => [id, name, shortName, logoUrl, isOwnTeam];
}
