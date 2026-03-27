abstract class UseCase<Type, Params> {
  const UseCase();
  Future<Type> call(Params params);
}

class NoParams {
  const NoParams();
}
