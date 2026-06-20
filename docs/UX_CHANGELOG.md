# UX Changelog — Space Mission Architect

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
