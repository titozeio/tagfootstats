import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final bool isOwnTeam;

  const Team({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isOwnTeam = false,
  });

  @override
  List<Object?> get props => [id, name, logoUrl, isOwnTeam];
}
