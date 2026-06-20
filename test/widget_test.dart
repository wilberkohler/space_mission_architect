import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_mission_architect/main.dart';

void main() {
  testWidgets('renders opening screen smoke test', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(const SpaceMissionArchitectApp());
    await tester.pump();

    expect(find.text('Space Mission Architect'), findsOneWidget);
    expect(find.text('Iniciar Campanha'), findsOneWidget);
  });
}
