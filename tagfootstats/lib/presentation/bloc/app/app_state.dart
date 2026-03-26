part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppNoTeam extends AppState {}

class AppReady extends AppState {
  final Team ownTeam;
  const AppReady({required this.ownTeam});

  @override
  List<Object?> get props => [ownTeam];
}

class AppError extends AppState {
  final String message;
  const AppError(this.message);

  @override
  List<Object?> get props => [message];
}
