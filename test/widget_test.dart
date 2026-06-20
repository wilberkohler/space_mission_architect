import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_mission_architect/game/game_controller.dart';
import 'package:space_mission_architect/main.dart';
import 'package:space_mission_architect/screens/mission_tree_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'),
            (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'awaitSpeakCompletion':
        case 'setSpeechRate':
        case 'setPitch':
        case 'setVolume':
        case 'setLanguage':
        case 'setVoice':
        case 'speak':
        case 'stop':
          return 1;
        case 'getVoices':
          return <Map<String, String>>[
            <String, String>{'name': 'Teste pt-BR', 'locale': 'pt-BR'},
          ];
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
  });

  testWidgets('renderiza a tela inicial do app real',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(const SpaceMissionArchitectApp());
    await tester.pump();

    expect(find.text('Space Mission Architect'), findsOneWidget);
    expect(find.text('Iniciar Campanha'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('renderiza arvore de missoes com busca e filtros',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final GameController controller = GameController();
    controller.selectAgency(controller.agencies.first);

    await tester.pumpWidget(
      MaterialApp(
        home: MissionTreeScreen(controller: controller),
      ),
    );
    await tester.pump();

    expect(find.text('Árvore de Missões'), findsOneWidget);
    expect(find.text('Filtros'), findsWidgets);
    expect(find.textContaining('missões'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar missões'), findsOneWidget);
    expect(find.text('Disponíveis'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
