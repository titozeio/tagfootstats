import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/data/models/tournament_model.dart';
import 'package:tagfootstats/data/repositories/firestore_tournament_repository.dart';
import 'package:tagfootstats/domain/entities/tournament.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late FirestoreTournamentRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockQueryDocumentSnapshot;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
    mockDocumentSnapshot = MockDocumentSnapshot();

    repository = FirestoreTournamentRepository(firestore: mockFirestore);

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);
  });

  final tTournament = Tournament(
    id: '1',
    name: 'Test Tournament',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 31),
    type: TournamentType.liga,
  );

  final tTournamentModel = TournamentModel.fromEntity(tTournament);

  group('getTournaments', () {
    test(
      'should return list of tournaments when firestore returns data',
      () async {
        when(
          () => mockCollection.get(),
        ).thenAnswer((_) async => mockQuerySnapshot);
        when(
          () => mockQuerySnapshot.docs,
        ).thenReturn([mockQueryDocumentSnapshot]);
        when(() => mockQueryDocumentSnapshot.id).thenReturn('1');
        when(() => mockQueryDocumentSnapshot.data()).thenReturn({
          'name': 'Test Tournament',
          'startDate': '2026-01-01T00:00:00.000',
          'endDate': '2026-01-31T00:00:00.000',
          'type': 'liga',
        });

        final result = await repository.getTournaments();

        expect(result, [tTournamentModel]);
        verify(() => mockFirestore.collection('tournaments')).called(1);
        verify(() => mockCollection.get()).called(1);
      },
    );
  });

  group('saveTournament', () {
    test('should call set on firestore with correct data', () async {
      when(() => mockDocument.set(any(), any())).thenAnswer((_) async => {});

      await repository.saveTournament(tTournament);

      verify(() => mockFirestore.collection('tournaments')).called(1);
      verify(() => mockCollection.doc('1')).called(1);
      verify(() => mockDocument.set(any(), any())).called(1);
    });
  });
}
