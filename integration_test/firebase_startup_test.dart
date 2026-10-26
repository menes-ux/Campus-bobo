import 'package:campus_bobo/main.dart' as app;
import 'package:campus_bobo/features/auth/presentation/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android starts with the Campus Bobo Firebase project', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(Firebase.app().options.projectId, 'campus-bobo');
    expect(find.byType(AuthGate), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
