# UX Changelog

## 2026-06-20 — Modularização inicial do Planejamento de Missão

### Resumo

A `MissionPlanningScreen` foi reduzida sem alterar comportamento visual relevante, fórmulas, resultado de missão, orçamento, risco, reputação, XP ou fluxo de lançamento. A etapa extraiu widgets puros de composição para `lib/screens/mission_planning/widgets/` e manteve cálculos/callbacks principais na tela.

### Arquivos criados

- `lib/screens/mission_planning/widgets/mission_header_card.dart`
- `lib/screens/mission_planning/widgets/planning_action_dock.dart`
- `lib/screens/mission_planning/widgets/budget_planner_card.dart`
- `lib/screens/mission_planning/widgets/chance_risk_card.dart`
- `lib/screens/mission_planning/widgets/test_history_banner.dart`
- `lib/screens/mission_planning/widgets/calibration_workbench.dart`
- `lib/screens/mission_planning/widgets/support_modules_section.dart`

### Correções feitas

- Corrigidos labels visíveis sem acento nos trechos tocados da `MissionPlanningScreen` e nos widgets extraídos.
- Substituído `withOpacity` por `withValues(alpha: ...)` nos arquivos da etapa.
- Adicionada API pública estreita `GameController.applyReputationDelta` para substituir chamada externa a `notifyListeners`, preservando os mesmos deltas usados no replanejamento.

### Extrações adiadas

- Os painéis internos de componentes, equipe, testes e variáveis permaneceram na `MissionPlanningScreen`, pois ainda concentram `setState`, sliders e seleção. Eles ficam para uma etapa posterior mais controlada.

### Resultado dos comandos

- `flutter pub get`: passou.
- `flutter analyze`: ainda falha com 168 issues antigos fora da etapa; os arquivos de `MissionPlanningScreen`, `mission_planning/widgets/` e `GameController` não retornaram issues na checagem filtrada.
- `flutter test`: passou com 10 testes.

### Riscos restantes

- O backlog global de análise permanece fora desta etapa, principalmente em `MissionTrackingScreen`, tema e widgets antigos com `withOpacity`.
- Não houve alteração de mecânicas, fórmulas, dados mockados, assets de áudio, dependências ou fluxo de lançamento.

## 2026-06-20 — Modularização da Árvore de Missões

### Resumo

A `MissionTreeScreen` foi reduzida e organizada com widgets dedicados em `lib/screens/mission_tree/widgets/`, mantendo o comportamento visual e a lógica de filtro, busca, seleção e navegação.

### Arquivos criados

- `lib/screens/mission_tree/mission_tree_filter.dart`
- `lib/screens/mission_tree/widgets/mission_tree_filter_bar.dart`
- `lib/screens/mission_tree/widgets/mission_tree_filter_sheet.dart`
- `lib/screens/mission_tree/widgets/mission_tree_empty_state.dart`
- `lib/screens/mission_tree/widgets/compact_graph_hint.dart`
- `lib/screens/mission_tree/widgets/recommended_mission_banner.dart`

### Resultado dos comandos

- `flutter analyze`: ainda falha com 206 issues antigos fora da etapa; os arquivos da árvore modularizada não retornaram issues na checagem filtrada.
- `flutter test`: passou com 10 testes.

### Riscos restantes

- O backlog global de análise permanece fora desta etapa.
- Não houve alteração de mecânica, dados mockados, desbloqueios, fórmulas ou `MissionPlanningScreen`.

## 2026-06-20 — Recomendação no Mapa de Campanha

### Resumo

A `MissionTreeScreen` ganhou um banner compacto de próxima missão recomendada acima da árvore. A recomendação usa apenas leitura da lista atual de missões: primeira missão disponível ordenada por ano, dificuldade e complexidade.

### Comportamento

- O botão `Selecionar` atualiza somente a seleção visual da árvore e do painel de detalhe.
- Quando a missão recomendada está fora do filtro ou busca atual, a tela mostra o aviso `A missão recomendada está fora do filtro atual` e oferece a ação `Mostrar disponíveis`.
- Quando não há missão disponível, a tela mostra a mensagem curta `Nenhuma missão disponível no momento`.
- Em alturas pequenas, a tela passa a rolar para evitar overflow mantendo busca, banner, árvore, detalhes e legenda acessíveis.

### Resultado dos comandos

- `flutter analyze`: ainda falha com 206 issues antigos fora da etapa; `MissionTreeScreen` e `widget_test.dart` não retornaram issues na checagem filtrada.
- `flutter test`: passou com 10 testes.

### Riscos restantes

- O backlog global de análise permanece fora desta etapa.
- A recomendação não altera status, desbloqueio, missão selecionada no `GameController`, fórmulas ou dados mockados.

## 2026-06-20 — Estabilização do PR #2

### Correções feitas

- Corrigidos labels visíveis sem acento em telas/componentes tocados nesta etapa: `Agência`, `Orçamento`, `Escolher Agência`, `Disponível`, `Ciência`, `Indústria` e `Reputação`.
- Substituídos usos pontuais de APIs depreciadas em arquivos estabilizados: `withOpacity` por `withValues(alpha: ...)` e `Matrix4.translate` por `translateByDouble`.
- Ajustada a responsividade da árvore de missões em telas estreitas: legenda com rolagem horizontal, estado vazio rolável e chips com ellipsis para evitar overflow.
- Ajustada a navegação inferior compartilhada para rolar horizontalmente quando a largura não comportar todos os itens.
- Ampliados testes de widget para cobrir filtro, busca, filtro + busca, estado vazio com limpeza, bottom sheet em tela pequena, estado vazio da central da campanha, resumo da agência selecionada e navegação para árvore/rivais.

### Resultado dos comandos

- `flutter pub get`: passou.
- `flutter analyze`: ainda falha com 206 issues de backlog antigo fora dos arquivos estabilizados; a checagem filtrada dos arquivos tocados nesta etapa não retornou issues.
- `flutter test`: passou com 8 testes.

### Riscos restantes

- O projeto ainda tem backlog antigo de lints/depreciações em telas e widgets fora do escopo desta etapa, especialmente `MissionPlanningScreen`, `MissionTrackingScreen`, componentes de missão/testes e tema.
- Ainda existem textos antigos sem acento em dados mockados e telas não tocadas; eles não foram alterados para preservar o escopo e evitar mexer em dados mockados.
- Não houve alteração de mecânicas, fórmulas, desbloqueios, XP, resultados de missão, dados mockados, assets de áudio ou dependências.

## 2026-06-20 — Melhoria da Árvore de Missões

### Resumo

A `MissionTreeScreen` foi melhorada para funcionar como um mapa de campanha mais acionável. A tela agora combina filtro por status, busca textual e painel de detalhes mais claro para missões disponíveis e bloqueadas.

### Filtros criados

- Todas
- Disponíveis
- Bloqueadas
- Concluídas
- Parciais
- Falhas

O filtro atual fica visível na barra da árvore, junto da contagem de missões exibidas, e pode ser limpo para voltar ao estado `Todas`.

### Busca criada

A busca textual filtra por nome, tipo, era e ano. A busca combina com o filtro de status ativo. Quando não há resultado, a tela mostra um estado vazio com a mensagem `Nenhuma missão encontrada para os filtros atuais` e uma ação para limpar busca e filtros.

### Melhorias nos bloqueios

- Missões bloqueadas agora mostram uma seção `Como desbloquear`.
- Motivos retornados por `GameController.missionBlockReasons` são reaproveitados.
- Requisitos por ID em `requiredMissions` são exibidos com o nome amigável da missão quando possível.
- O painel destaca orçamento, reputação e cargo/carreira necessários.

### Melhorias em missões disponíveis

- O painel destaca que a missão pode ser planejada agora.
- O botão principal `Planejar missão` ficou mais claro.
- Orçamento mínimo, orçamento recomendado, complexidade, dificuldade, requisito de carreira e riscos principais aparecem de forma mais explícita.

### Arquivos alterados

- `lib/screens/mission_tree_screen.dart`
- `lib/widgets/mission_detail_panel.dart`
- `lib/widgets/mission_legend.dart`
- `test/widget_test.dart`
- `docs/UX_CHANGELOG.md`
- `docs/UX_ROADMAP.md`

### Riscos conhecidos

- A filtragem altera apenas a visualização da árvore; não muda status, desbloqueios nem regras de campanha.
- Em filtros muito restritos, conexões entre missões podem ficar ocultas porque os nós fora do filtro não são exibidos.
- `flutter analyze` segue falhando por backlog preexistente de lints/infos do projeto, embora `flutter test` passe.

## 2026-06-20 — Central da Campanha

### Resumo

Foi criada a `CampaignHubScreen`, uma Central da Campanha posicionada entre a seleção de agência e a árvore de missões. A tela organiza o contexto da campanha, recomenda a próxima missão disponível, mostra progresso geral e apresenta um resumo dos rivais.

### Componentes compartilhados criados

- `SpacePanel`: painel visual padrão para seções e cards.
- `MetricTile`: bloco de métrica com ícone, título, valor e subtítulo opcional.
- `StatusPill`: marcador textual compacto com ícone opcional.
- `SectionHeader`: cabeçalho de seção com subtítulo e ação opcional.
- `EmptyState`: estado vazio com mensagem e ação opcional.
- `PrimaryObjectiveCard`: card de objetivo principal com chamada clara para a próxima ação.

### Fluxo alterado

Fluxo anterior:

HomeScreen → AgencySelectionScreen → MissionTreeScreen

Novo fluxo:

HomeScreen → AgencySelectionScreen → CampaignHubScreen → MissionTreeScreen

### Riscos conhecidos

- A Central da Campanha ainda usa leitura direta do `GameController`, sem view model dedicado.
- A recomendação de missão usa a primeira missão disponível e acessível, sem sistema avançado de priorização.
- `flutter analyze` ainda falha por lints e avisos preexistentes no projeto, principalmente depreciações e uso protegido de APIs em telas antigas.
- O app ainda tem inconsistências antigas de idioma/acentuação em telas existentes; esta etapa manteve o foco apenas na nova tela e nos novos componentes.

### Próximos passos

- Validar manualmente o novo fluxo com seleção de agência, abertura da árvore e abertura de rivais.
- Criar testes de navegação para Agency → Campaign Hub → Mission Tree em uma etapa futura.
- Evoluir a Central da Campanha com dados de progresso mais didáticos quando houver persistência ou view models.
- Continuar o roadmap P1 melhorando a navegação e a árvore de missões.
