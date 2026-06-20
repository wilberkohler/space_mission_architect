# Architecture Audit — Space Mission Architect

## Visão geral

Space Mission Architect é um app Flutter/Dart com uma arquitetura de protótipo avançado: modelos, dados mockados, engine de jogo, controller central, telas e widgets reutilizáveis. A base é promissora, mas algumas classes concentram responsabilidades demais e precisam ser modularizadas gradualmente.

## Estrutura atual de pastas

```text
lib/
  audio/
  data/
  game/
  models/
  screens/
  theme/
  utils/
  widgets/
```

## Responsabilidades atuais

### `lib/main.dart`

Cria o `SpaceMissionArchitectApp`, inicializa um `GameController`, aplica o tema e abre a `HomeScreen`.

### `lib/theme/app_theme.dart`

Centraliza boa parte do design system: cores, espaçamentos, raios, sombras, decorações e `ThemeData` escuro. É um ponto forte do projeto e deve continuar sendo a fonte visual principal.

### `lib/game/game_controller.dart`

Atualmente concentra:

- agências;
- missões;
- variáveis da missão;
- componentes;
- equipe;
- opções de teste;
- rivais;
- carreira;
- seleção de agência;
- seleção de missão;
- orçamento;
- reputação;
- histórico de evento mais recente;
- resultado e relatório;
- compatibilidade com sliders legados;
- desbloqueio de missões;
- cálculo agregado de planejamento.

Essa concentração é aceitável para MVP, mas deve ser reduzida gradualmente para evitar acoplamento entre UI, campanha e mecânicas.

### `lib/game/mock_game_engine.dart`

Contém lógica de filtragem por complexidade, estimativa de risco, testes, lançamento, geração de resultados, desbloqueios e XP. Esta camada deve permanecer como fonte de regras de jogo, evitando duplicação nas telas.

### `lib/screens/home_screen.dart`

Responsável por:

- layout da abertura;
- controle TTS;
- seleção de voz;
- idioma;
- narração em partes;
- crawl de abertura;
- música de fundo;
- fallback para Windows;
- navegação para seleção de agência.

A tela deve ser refatorada futuramente para delegar narração e preferências a serviços/controladores menores.

### `lib/screens/agency_selection_screen.dart`

Tela de escolha de agência com cards, hover, feedback sonoro e navegação. É uma tela relativamente simples e boa candidata a usar componentes compartilhados no futuro.

### `lib/screens/mission_tree_screen.dart`

Tela de árvore de missões com cockpit scaffold, grafo, detalhe e acesso a planejamento/rivais. A estrutura é boa, mas o filtro ainda precisa de implementação e a explicação de bloqueios pode melhorar.

### `lib/screens/mission_planning_screen.dart`

Tela mais densa do app. Concentra:

- layout responsivo;
- action dock;
- testes;
- histórico de testes;
- orçamento;
- chance/risco;
- componentes;
- equipe;
- variáveis;
- launch readiness;
- confirmação de risco de teste;
- bloqueios por orçamento;
- countdown de lançamento;
- navegação para tracking.

Deve ser modularizada antes de novas features complexas.

### `lib/screens/mission_tracking_screen.dart`

Responsável pela simulação em tempo real, timer, fases, risco, recursos, eventos críticos, estabilidade, logs e resultado. Deve preservar regras, mas pode ganhar uma camada de view model para separar estado de simulação e apresentação.

### `lib/screens/mission_report_screen.dart`

Mostra resultado final e próximos caminhos. Pode ser reorganizada como debriefing didático.

### `lib/screens/rivals_screen.dart`

Mostra ranking de rivais. Tela simples, útil para reaproveitar em uma futura Central da Campanha.

## Componentes reutilizáveis já existentes

- `ControlCard`
- `GameCockpitScaffold`
- `CompactMissionHeader`
- `MissionTreeGraph`
- `MissionDetailPanel`
- `MissionLegend`
- `VariableSlider`
- `CountdownPanel`
- `GuidancePanel`
- `LaunchReadinessModal`
- `TestCountdownModal`
- `TestResultModal`
- `MissionReportCard`
- `MissionEventLog`
- `MissionPhaseTimeline`
- `MissionTrajectoryView`
- `StabilityBalanceControl`

## Pontos onde UI e lógica estão misturadas

1. `HomeScreen`: lógica de TTS e áudio dentro da tela.
2. `MissionPlanningScreen`: lógica de orçamento, testes, bloqueio de lançamento e modais dentro da tela.
3. `MissionTrackingScreen`: lógica de simulação temporal e UI no mesmo `State`.
4. `MissionReportScreen`: montagem de dados de relatório dentro da tela.

## Candidatos a extração futura

### Services

- `IntroNarrationService`
- `AudioPreferenceService`
- `CampaignProgressService`
- `MissionRecommendationService`

### View models

- `CampaignHubViewModel`
- `MissionTreeViewModel`
- `MissionPlanningViewModel`
- `MissionTrackingViewModel`
- `MissionReportViewModel`

### Componentes compartilhados

- `SpacePanel`
- `MetricTile`
- `StatusPill`
- `SectionHeader`
- `EmptyState`
- `PrimaryObjectiveCard`
- `ResponsiveTwoColumn`

## Riscos de continuar sem reorganização

- Dificuldade de testar mecânicas isoladamente.
- Duplicação de cálculo em telas.
- Crescimento de telas muito grandes.
- Mudanças visuais quebrarem comportamento de jogo.
- Navegação ficar inconsistente.
- Áudio/TTS ficar difícil de controlar e depurar.
- A campanha parecer uma sequência de telas, não um loop de jogo.

## Direção arquitetural recomendada

Evoluir gradualmente para:

```text
UI Widgets → View Models → GameController / Services → Game Engine / Calculators → Models / Data
```

Regras práticas:

1. Widgets exibem dados e disparam ações.
2. View models preparam dados para tela.
3. GameController mantém estado de campanha, mas deve reduzir responsabilidade com o tempo.
4. Game engine e calculators mantêm regras de jogo.
5. Dados mockados continuam sendo fonte local enquanto não houver persistência.

## Próxima mudança segura

Criar uma `CampaignHubScreen` usando componentes compartilhados. Essa mudança melhora o fluxo sem alterar regras, cálculos ou dados.
