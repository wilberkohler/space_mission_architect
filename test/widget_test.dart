import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_mission_architect/game/game_controller.dart';
import 'package:space_mission_architect/main.dart';
import 'package:space_mission_architect/screens/campaign_hub_screen.dart';
import 'package:space_mission_architect/screens/mission_tree_screen.dart';
import 'package:space_mission_architect/screens/rivals_screen.dart';

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

  testWidgets('renderiza árvore de missões com busca e filtros',
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
    expect(find.text('Próxima missão recomendada'), findsOneWidget);
    expect(find.text('Foguete Experimental'), findsWidgets);
    expect(find.text('Selecionar'), findsOneWidget);
    expect(find.text('Filtros'), findsWidgets);
    expect(find.textContaining('missões'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar missões'), findsOneWidget);
    expect(find.text('Disponíveis'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('combina filtro, busca e estado vazio da árvore de missões',
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

    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloqueadas'));
    await tester.pumpAndSettle();

    expect(find.text('Filtro: Bloqueadas'), findsOneWidget);
    expect(find.text('5 missões'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Satelite');
    await tester.pump();

    expect(find.text('1 missões'), findsOneWidget);
    expect(find.text('Primeiro Satelite Orbital'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'sem resultado');
    await tester.pump();

    expect(find.text('Nenhuma missão encontrada'), findsOneWidget);
    expect(
      find.text('Nenhuma missão encontrada para os filtros atuais.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Limpar busca e filtros'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpar busca e filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Filtro: Todas'), findsOneWidget);
    expect(find.text('6 missões'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('seleciona visualmente a próxima missão recomendada',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final GameController controller = GameController();
    controller.selectAgency(controller.agencies.first);
    controller.selectMission(controller.missions[1]);

    await tester.pumpWidget(
      MaterialApp(
        home: MissionTreeScreen(controller: controller),
      ),
    );
    await tester.pump();

    expect(find.text('Sputnik 1 / Explorer 1'), findsOneWidget);

    await tester.tap(find.text('Selecionar'));
    await tester.pump();

    expect(find.text('Testes iniciais de foguetes'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('mostra aviso quando recomendada fica fora do filtro',
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

    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloqueadas'));
    await tester.pumpAndSettle();

    expect(
      find.text('A missão recomendada está fora do filtro atual'),
      findsOneWidget,
    );
    expect(find.text('Mostrar disponíveis'), findsOneWidget);

    await tester.tap(find.text('Mostrar disponíveis'));
    await tester.pumpAndSettle();

    expect(find.text('Filtro: Disponíveis'), findsOneWidget);
    expect(find.text('1 missões'), findsOneWidget);
    expect(find.text('Testes iniciais de foguetes'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('bottom sheet de filtros cabe em tela pequena',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    tester.view.physicalSize = const Size(360, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final GameController controller = GameController();
    controller.selectAgency(controller.agencies.first);

    await tester.pumpWidget(
      MaterialApp(
        home: MissionTreeScreen(controller: controller),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar missões'), findsOneWidget);
    expect(find.text('Falhas'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('central da campanha mostra estado vazio sem agência',
      (WidgetTester tester) async {
    final GameController controller = GameController();

    await tester.pumpWidget(
      MaterialApp(
        home: CampaignHubScreen(controller: controller),
      ),
    );
    await tester.pump();

    expect(find.text('Selecione uma agência'), findsOneWidget);
    expect(
      find.textContaining('missões, orçamento e rivais'),
      findsOneWidget,
    );
  });

  testWidgets('central da campanha mostra resumo da agência selecionada',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final GameController controller = GameController();
    controller.selectAgency(controller.agencies.first);

    await tester.pumpWidget(
      MaterialApp(
        home: CampaignHubScreen(controller: controller),
      ),
    );
    await tester.pump();

    expect(find.text('NASA'), findsWidgets);
    expect(find.text('Orçamento'), findsOneWidget);
    expect(find.text('1200M'), findsOneWidget);
    expect(find.text('Cargo'), findsOneWidget);
    expect(find.text('Pública'), findsOneWidget);
    expect(find.text('Reputação'), findsWidgets);
    expect(find.text('Objetivo principal'), findsOneWidget);
    expect(find.text('Foguete Experimental'), findsOneWidget);
    expect(find.text('Progresso da campanha'), findsOneWidget);
    expect(find.text('Rivais'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('botão de missão da central abre a árvore',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final GameController controller = GameController();
    controller.selectAgency(controller.agencies.first);

    await tester.pumpWidget(
      MaterialApp(
        home: CampaignHubScreen(controller: controller),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Escolher missão').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher missão').first);
    await tester.pumpAndSettle();

    expect(find.byType(MissionTreeScreen), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('botão de rivais da central abre a tela de rivais',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final GameController controller = GameController();
    controller.selectAgency(controller.agencies.first);

    await tester.pumpWidget(
      MaterialApp(
        home: CampaignHubScreen(controller: controller),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Ver rivais').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver rivais').first);
    await tester.pumpAndSettle();

    expect(find.byType(RivalsScreen), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
