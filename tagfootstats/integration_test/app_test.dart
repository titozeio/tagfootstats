import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tagfootstats/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Integración - TagFootStats', () {
    testWidgets('Flujo completo de inicio y navegación', (tester) async {
      // Arranca la app
      app.main();
      await tester.pumpAndSettle();

      // Verifica que estamos en la Home Page (buscando el título o algún elemento clave)
      expect(find.text('TagFootStats'), findsOneWidget);

      // Navegación a Partidos
      await tester.tap(find.text('Partidos'));
      await tester.pumpAndSettle();
      expect(
        find.text('Partidos'),
        findsWidgets,
      ); // El label del nav bar y el título

      // Navegación a Equipos
      await tester.tap(find.text('Equipos'));
      await tester.pumpAndSettle();
      expect(find.text('Equipos'), findsWidgets);

      // Navegación a Torneos
      await tester.tap(find.text('Torneos'));
      await tester.pumpAndSettle();
      expect(find.text('Torneos'), findsWidgets);

      // Navegación a Ajustes
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      expect(find.text('Ajustes'), findsWidgets);

      // Volver a Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('TagFootStats'), findsOneWidget);
    });
  });
}
