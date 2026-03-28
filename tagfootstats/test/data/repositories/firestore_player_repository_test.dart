import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagfootstats/data/models/player_model.dart';
import 'package:tagfootstats/data/repositories/firestore_player_repository.dart';
import 'package:tagfootstats/domain/entities/player.dart';

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
  late FirestorePlayerRepository repository;
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

    repository = FirestorePlayerRepository(firestore: mockFirestore);

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);
  });

  final tPlayer = Player(
    id: '1',
    teamId: 'team1',
    firstName: 'John',
    lastName: 'Doe',
    dorsal: 10,
  );

  final tPlayerModel = PlayerModel.fromEntity(tPlayer);

  group('getPlayersByTeam', () {
    test('should return players for a specific team', () async {
      final mockQuery = MockCollectionReference(); // Mocking Query
      when(
        () => mockCollection.where('teamId', isEqualTo: 'team1'),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn([mockQueryDocumentSnapshot]);
      when(() => mockQueryDocumentSnapshot.id).thenReturn('1');
      when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        'teamId': 'team1',
        'firstName': 'John',
        'lastName': 'Doe',
        'dorsal': 10,
      });

      final result = await repository.getPlayersByTeam('team1');

      expect(result, [tPlayerModel]);
    });
  });
}
