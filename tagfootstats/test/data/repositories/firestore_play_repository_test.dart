import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/data/models/play_model.dart';
import 'package:tagfootstats/data/repositories/firestore_play_repository.dart';
import 'package:tagfootstats/domain/entities/play.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

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
        final mockQuery1 = MockCollectionReference();
        final mockQuery2 = MockCollectionReference();

        when(
          () => mockCollection.where('matchId', isEqualTo: 'm1'),
        ).thenReturn(mockQuery1);
        when(
          () => mockQuery1.orderBy('minute', descending: false),
        ).thenReturn(mockQuery2);
        when(() => mockQuery2.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(
          () => mockQuerySnapshot.docs,
        ).thenReturn([mockQueryDocumentSnapshot]);
        when(() => mockQueryDocumentSnapshot.id).thenReturn('1');
        when(() => mockQueryDocumentSnapshot.data()).thenReturn({
          'matchId': 'm1',
          'phase': 'ataque',
          'minute': 5,
          'action': 'Pass',
          'outcome': 'Complete',
          'points': 0,
          'yardas': 10,
          'involvedPlayerIds': ['p1'],
        });

        final result = await repository.getPlaysByMatch('m1');

        expect(result, [tPlayModel]);
      },
    );
  });
}
