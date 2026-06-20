# UX Changelog

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
