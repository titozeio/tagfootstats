import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/data/models/play_model.dart';
import 'package:tagfootstats/data/repositories/firestore_play_repository.dart';
import 'package:tagfootstats/domain/entities/play.dart';

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
  late FirestorePlayRepository repository;
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

    repository = FirestorePlayRepository(firestore: mockFirestore);

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);
  });

  final tPlay = Play(
    id: '1',
    matchId: 'm1',
    phase: PlayPhase.ataque,
    minute: 5,
    action: 'Pass',
    outcome: 'Complete',
    points: 0,
    yardas: 10,
    involvedPlayerIds: const ['p1'],
  );

  final tPlayModel = PlayModel.fromEntity(tPlay);

  group('getPlaysByMatch', () {
    test(
      'should return plays for a specific match ordered by minute',
      () async {
        final secondPlaySnapshot = MockQueryDocumentSnapshot();

        when(
          () => mockCollection.where('matchId', isEqualTo: 'm1'),
        ).thenReturn(mockCollection);
        when(
          () => mockCollection.get(),
        ).thenAnswer((_) async => mockQuerySnapshot);
        when(
          () => mockQuerySnapshot.docs,
        ).thenReturn([mockQueryDocumentSnapshot, secondPlaySnapshot]);
        when(() => mockQueryDocumentSnapshot.id).thenReturn('1');
        when(() => mockQueryDocumentSnapshot.data()).thenReturn({
          'matchId': 'm1',
          'phase': 'ataque',
          'minute': 9,
          'action': 'Pass',
          'outcome': 'Complete',
          'points': 0,
          'yardas': 10,
          'involvedPlayerIds': ['p1'],
        });
        when(() => secondPlaySnapshot.id).thenReturn('2');
        when(() => secondPlaySnapshot.data()).thenReturn({
          'matchId': 'm1',
          'phase': 'ataque',
          'minute': 5,
          'action': 'Run',
          'outcome': 'Success',
          'points': 0,
          'yardas': 4,
          'involvedPlayerIds': ['p2'],
        });

        final result = await repository.getPlaysByMatch('m1');

        expect(result.map((play) => play.minute).toList(), [5, 9]);
        expect(result.first.id, '2');
        expect(result.last.id, '1');
      },
    );
  });
}
