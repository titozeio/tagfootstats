import 'package:equatable/equatable.dart';

enum PlayerPosition { offense, defense, both }

class Player extends Equatable {
  final String id;
  final String teamId;
  final String firstName;
  final String lastName;
  final int dorsal;
  final DateTime? birthDate;
  final String? email;
  final String? phone;
  final PlayerPosition position;
  final String? photoUrl;

  const Player({
    required this.id,
    required this.teamId,
    required this.firstName,
    required this.lastName,
    required this.dorsal,
    this.birthDate,
    this.email,
    this.phone,
    this.position = PlayerPosition.both,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    teamId,
    firstName,
    lastName,
    dorsal,
    birthDate,
    email,
    phone,
    position,
    photoUrl,
  ];
}
