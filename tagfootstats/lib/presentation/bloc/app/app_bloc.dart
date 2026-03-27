import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../domain/entities/team.dart';
import '../../../domain/repositories/team_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final TeamRepository teamRepository;

  AppBloc({required this.teamRepository}) : super(AppInitial()) {
    on<InitializeApp>(_onInitialize);
  }

  Future<void> _onInitialize(
    InitializeApp event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      final ownTeam = await teamRepository.getOwnTeam().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception(
          'Connection timeout (30s). Please check your internet connection.',
        ),
      );

      if (ownTeam == null) {
        emit(AppNoTeam());
      } else {
        emit(AppReady(ownTeam: ownTeam));
      }
    } on FirebaseException catch (e) {
      emit(AppError('FIREBASE ERROR: ${e.message}'));
    } catch (e) {
      emit(AppError('CONNECTION ERROR: ${e.toString()}'));
    }
  }
}
