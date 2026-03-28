import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/data/models/match_model.dart';
import 'package:tagfootstats/data/repositories/firestore_match_repository.dart';
import 'package:tagfootstats/domain/entities/match.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late FirestoreMatchRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockQueryDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

    repository = FirestoreMatchRepository(firestore: mockFirestore);

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);
  });

  final tMatch = Match(
    id: '1',
    tournamentId: 't1',
    opponentId: 'opp1',
    dateTime: DateTime(2026, 1, 1),
    locationType: LocationType.local,
    homeScore: 0,
    awayScore: 0,
  );

  final tMatchModel = MatchModel.fromEntity(tMatch);

  group('getMatchesByTournament', () {
    test('should return matches for a specific tournament', () async {
      final mockQuery = MockCollectionReference();
      when(
        () => mockCollection.where('tournamentId', isEqualTo: 't1'),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn([mockQueryDocumentSnapshot]);
      when(() => mockQueryDocumentSnapshot.id).thenReturn('1');
      when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        'tournamentId': 't1',
        'opponentId': 'opp1',
        'dateTime': '2026-01-01T00:00:00.000',
        'locationType': 'local',
        'homeScore': 0,
        'awayScore': 0,
      });

      final result = await repository.getMatchesByTournament('t1');

      expect(result, [tMatchModel]);
    });
  });
}
