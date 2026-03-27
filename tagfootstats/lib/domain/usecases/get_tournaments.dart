import '../entities/tournament.dart';
import '../repositories/tournament_repository.dart';
import 'usecase.dart';

class GetTournaments extends UseCase<List<Tournament>, NoParams> {
  final TournamentRepository repository;

  GetTournaments(this.repository);

  @override
  Future<List<Tournament>> call(NoParams params) async {
    return await repository.getTournaments();
  }
}
