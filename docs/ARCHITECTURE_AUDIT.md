# Architecture Audit

## Escopo

Auditoria estrutural inicial do Space Mission Architect em 2026-06-20. O objetivo é documentar a base antes de implementar novas funcionalidades de UX.

## Estrutura atual de pastas

- `lib/main.dart`: ponto de entrada, cria `SpaceMissionArchitectApp`, instancia `GameController` e renderiza `HomeScreen`.
- `lib/audio`: gerenciamento de áudio, efeitos, configurações e modal de áudio.
- `lib/data`: dados mockados de agências, carreiras, componentes, missões, fases, rivais e testes.
- `lib/game`: controller, simuladores, calculadoras e engine mockada.
- `lib/models`: modelos de domínio do jogo.
- `lib/screens`: telas principais e modais de tela.
- `lib/theme`: tema visual, cores, raios, espaçamentos e decorações.
- `lib/utils`: constantes e formatadores.
- `lib/widgets`: componentes reutilizáveis de UI, painéis, cartões, árvore, telemetria, sliders e modais.
- `assets/audio`: assets locais de som, voz, ambiente e efeitos.
- `docs`: documentação visual existente e novos documentos de auditoria.
- `test`: testes Flutter.

## Responsabilidades dos principais módulos

- `GameController`: estado central da campanha e ponte entre dados mockados, escolhas do jogador, resultados, reputação, orçamento, XP, desbloqueios e relatório.
- `MockGameEngine`: regras auxiliares de complexidade, filtros de recursos, experiência e desbloqueios.
- `BudgetCalculator`: cálculo de orçamento de campanha/missão.
- `RiskCalculator` e `MissionSimulator`: regras de risco/simulação auxiliares.
- `AudioManager`: coordena música, ambiente, efeitos, voz e fallbacks.
- `GameCockpitScaffold`: moldura comum de telas internas com cabeçalho e navegação inferior.
- `MissionTreeGraph`, `MissionDetailPanel`, `MissionReportCard`, `VariableSlider`, `StabilityBalanceControl`: componentes reutilizáveis já extraídos.

## Análise do GameController

`GameController` tem cerca de 518 linhas e concentra muitas responsabilidades:

- seleção de agência e missão;
- estado de orçamento, reputação, carreira, XP e testes;
- filtros por complexidade de missão;
- compatibilidade com sliders legados;
- execução de teste mockado;
- mensagens de orientação e bloqueio;
- criação de relatório de missão;
- aplicação de resultado na árvore;
- disparo de áudio de desbloqueio.

Essa concentração funciona para protótipo, mas dificulta testes granulares e evolução do fluxo de campanha. O controller mistura estado de UI legado, regras de domínio, side effects de áudio e composição de relatório.

## Análise da HomeScreen

`HomeScreen` tem cerca de 624 linhas e combina:

- UI cinematográfica de abertura;
- TTS e seleção de voz;
- troca de locale da introdução;
- fallback de áudio específico para Windows com `just_audio`;
- controle do crawl textual;
- botões de áudio e início da campanha;
- camada visual de estrelas.

É uma tela forte em atmosfera, mas densa. Candidatos naturais de extração futura: serviço/adaptador de TTS, controlador de intro, widget de ações da Home e widget/camada de fundo.

## Análise da MissionPlanningScreen

`MissionPlanningScreen` tem cerca de 1812 linhas e é o principal ponto de acúmulo estrutural. A tela contém:

- layout responsivo;
- seleção e execução de testes;
- histórico de testes;
- variáveis e sliders;
- componentes;
- equipe;
- resumo de missão;
- cálculos de prontidão;
- bloqueios de lançamento;
- recuperação de bloqueio por orçamento;
- abertura de modais;
- navegação para acompanhamento.

Há lógica de UX e regras operacionais muito próximas da árvore de widgets. A próxima evolução deve modularizar sem alterar fórmulas: extrair widgets menores e, depois, view models para prontidão, seleção de testes e resumo.

## Análise da MissionTrackingScreen

`MissionTrackingScreen` tem cerca de 1039 linhas e concentra a simulação ao vivo:

- timer de missão;
- fases ativas;
- telemetria;
- consumo de recursos e orçamento;
- risco;
- eventos críticos;
- controle de estabilidade;
- coleta científica;
- aborto/encerramento;
- logs;
- decisão de sucesso/falha;
- transição para relatório.

A tela já usa `ValueNotifier` para reduzir rebuilds completos, o que é positivo. Ainda assim, o estado de simulação deveria migrar gradualmente para um modelo/controlador próprio para facilitar testes e reduzir risco de regressão.

## Análise da MissionReportScreen

`MissionReportScreen` tem cerca de 298 linhas e é mais simples, mas ainda mistura:

- leitura de `MissionResult`/`MissionReport`;
- composição de linhas de custo, reputação, ciência, desbloqueios e lições;
- áudio de resultado/desbloqueio;
- navegação para árvore, rivais e início.

Oportunidade futura: criar um view model de debriefing e padronizar rotas de saída.

## Componentes reutilizáveis já existentes

- Estrutura: `GameCockpitScaffold`, `CompactMissionHeader`, `ControlCard`.
- Planejamento: `VariableSlider`, `LaunchReadinessModal`, `CountdownPanel`, `RoundActionButton`, `GuidancePanel`.
- Testes: `TestCountdownModal`, `TestResultModal`, `TestCard`.
- Missão: `MissionTrajectoryView`, `MissionPhaseTimeline`, `MissionEventLog`, `StabilityBalanceControl`, `CriticalActionButton`.
- Árvore: `MissionTreeGraph`, `MissionNode`, `MissionDetailPanel`, `MissionLegend`, `MissionCard`.
- Status: `BudgetPanel`, `ResourceStatusPanel`, `ReputationBar`, `CareerBadge`, `PhaseStatusPanel`, `TopStatusBar`.
- Relatório: `MissionReportCard`.
- Áudio/atmosfera: `NowPlayingIndicator`, `IntroCrawlWidget`, `LocalizedIntroText`.

## Pontos onde UI e lógica de jogo estão misturadas

- `MissionPlanningScreen`: seleção/execução de testes, prontidão de lançamento, bloqueio por orçamento e ajustes de equipe/variáveis dentro do State.
- `MissionTrackingScreen`: simulação temporal, eventos críticos e cálculo de sucesso/falha dentro do State.
- `GameController`: regras de campanha junto com side effects de áudio e aliases de UI legado.
- `HomeScreen`: TTS, áudio, locale e animação de abertura dentro da tela.
- `MissionReportScreen`: composição de debriefing e disparos de áudio dentro da tela.

## Candidatos a view models, services ou widgets menores

- `CampaignHubViewModel`: próximo objetivo, progresso, recursos, missão recomendada e alertas.
- `MissionPlanningViewModel`: prontidão, resumo de orçamento, testes selecionados e ações recomendadas.
- `TestSelectionController`: seleção, execução e histórico de testes.
- `LaunchReadinessViewModel`: critérios de GO/NO-GO e mensagens de bloqueio.
- `MissionLiveSimulationController`: timer, fase, telemetria, risco e eventos críticos.
- `MissionDebriefViewModel`: linhas de relatório, lições, desbloqueios e próximas ações.
- `IntroNarrationController` ou `IntroNarrationService`: TTS, vozes, chunks e crawl.
- Widgets menores para painéis de planejamento: resumo, componentes, equipe, testes, variáveis e ações principais.

## Riscos de continuar evoluindo sem reorganização

- Novas funcionalidades de UX tendem a aumentar telas já grandes, principalmente planejamento.
- Mudanças visuais podem alterar mecânicas sem intenção porque regras estão próximas da UI.
- Testes ficam difíceis quando domínio, áudio, navegação e widgets estão acoplados.
- Correções de idioma/acessibilidade podem ficar inconsistentes se cada tela resolver localmente.
- Navegação pode continuar crescendo por `Navigator.push` direto, sem uma estrutura clara de campanha.
- Performance pode degradar com mais missões, logs e animações se o estado ao vivo permanecer concentrado em telas.

## Recomendação estrutural

Manter a primeira reorganização incremental. A sequência mais segura é:

1. Documentar regras e estado atual.
2. Corrigir teste base.
3. Criar Central da Campanha sem remover telas existentes.
4. Introduzir view models leves para leitura de estado.
5. Modularizar `MissionPlanningScreen` em widgets menores sem alterar fórmulas.
6. Só depois extrair controladores de simulação e debriefing.
