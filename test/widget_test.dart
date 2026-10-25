import 'package:campus_bobo/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('The reporting guide opens and returns to the welcome screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeAuthRepository();
    addTearDown(repository.close);
    await tester.pumpWidget(CampusBoboApp(authRepository: repository));
    await tester.pumpAndSettle();
    final guideButton = find.widgetWithText(
      OutlinedButton,
      'How reporting works',
    );
    await tester.scrollUntilVisible(guideButton, 300);
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(guideButton), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(guideButton);
    await tester.pumpAndSettle();

    expect(find.text('Reporting guide'), findsOneWidget);
    expect(find.text('Describe what you noticed'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Your campus.\nA little better.'),
      -300,
    );
    await tester.pumpAndSettle();
    expect(find.text('Your campus.\nA little better.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
