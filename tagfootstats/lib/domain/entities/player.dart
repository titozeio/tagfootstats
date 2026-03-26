import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String teamId;
  final String firstName;
  final String lastName;
  final int dorsal;
  final DateTime? birthDate;
  final String? email;
  final String? phone;

  const Player({
    required this.id,
    required this.teamId,
    required this.firstName,
    required this.lastName,
    required this.dorsal,
    this.birthDate,
    this.email,
    this.phone,
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
      ];
}
