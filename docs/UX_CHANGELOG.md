# UX Changelog — Space Mission Architect

## 2026-06-20 — Central da Campanha

### Tipo

Nova etapa de UX em branch dedicada `ux-campaign-hub`.

### Arquivos criados

- `lib/screens/campaign_hub_screen.dart`
- `lib/widgets/shared/space_panel.dart`
- `lib/widgets/shared/metric_tile.dart`
- `lib/widgets/shared/status_pill.dart`
- `lib/widgets/shared/section_header.dart`
- `lib/widgets/shared/empty_state.dart`
- `lib/widgets/shared/primary_objective_card.dart`

### Arquivos alterados

- `lib/screens/agency_selection_screen.dart`
- `test/widget_test.dart`
- `docs/UX_CHANGELOG.md`

### Resumo

- Criada `CampaignHubScreen` como Central da Campanha entre seleção de agência e árvore de missões.
- Criados componentes compartilhados leves para padronizar a UI.
- A seleção de agência agora direciona para a Central da Campanha em vez de abrir diretamente a árvore.
- A Central da Campanha mostra agência, ano, orçamento, reputação, carreira, missão recomendada, progresso da campanha, resumo de rivais e ações rápidas.
- O smoke test foi ajustado para usar override de plataforma Windows durante o teste, reduzindo risco de chamadas de áudio em ambiente de teste.

### Regras preservadas

- Nenhuma mecânica de jogo alterada.
- Nenhuma fórmula de orçamento, risco, reputação, XP, desbloqueio ou resultado alterada.
- Nenhum asset de áudio alterado.
- Nenhuma dependência adicionada.
- Nenhum dado mockado alterado.

### Riscos conhecidos

- `flutter analyze` e `flutter test` ainda precisam ser executados em ambiente com Flutter instalado.
- A Central da Campanha usa dados já existentes do `GameController`; uma futura etapa pode extrair um `CampaignHubViewModel`.

### Próxima etapa recomendada

Rodar validação local ou no Codex com Flutter instalado. Em seguida, melhorar a árvore de missões com filtro funcional e explicação de bloqueios.

## 2026-06-20 — Fundação de UX e arquitetura

### Tipo

Documentação e correção de base mínima.

### Arquivos criados

- `AGENTS.md`
- `docs/UX_AUDIT.md`
- `docs/ARCHITECTURE_AUDIT.md`
- `docs/UX_ROADMAP.md`
- `docs/UX_CHANGELOG.md`

### Arquivos alterados

- `README.md`
- `test/widget_test.dart`

### Resumo

- Substituído README padrão de Flutter por documentação real do Space Mission Architect.
- Criadas instruções para futuras tarefas do Codex.
- Criada auditoria inicial de UX.
- Criada auditoria inicial de arquitetura.
- Criado roadmap de melhorias em P0, P1, P2 e P3.
- Corrigido smoke test para usar `SpaceMissionArchitectApp` em vez de app template.

### Regras preservadas

- Nenhuma mecânica de jogo alterada.
- Nenhuma fórmula de orçamento, risco, reputação, XP, desbloqueio ou resultado alterada.
- Nenhum asset de áudio alterado.
- Nenhuma dependência adicionada.
- Nenhuma tela nova criada.

### Próxima etapa recomendada

Criar `CampaignHubScreen` entre a seleção de agência e a árvore de missões, junto com componentes compartilhados leves em `lib/widgets/shared/`.
