# UX Roadmap — Space Mission Architect

## Norte do produto

Transformar o app em uma experiência de campanha espacial clara, leve, didática e audiovisual, onde o jogador entende:

```text
onde está;
qual é o objetivo atual;
quais decisões importam;
por que uma ação está bloqueada;
o que fazer para avançar;
o que aprendeu após cada missão.
```

## Fluxo-alvo

```text
Home cinematográfica
→ Seleção de agência
→ Central da Campanha
→ Árvore de Missões
→ Briefing da Missão
→ Planejamento
→ Testes
→ Revisão de Prontidão
→ Lançamento
→ Controle de Missão
→ Relatório / Debriefing
→ Progressão / Próxima Missão
```

## Status atual

- P0 Fundação: concluída em documentação/base mínima.
- P1 Central da Campanha: implementada na branch `ux-campaign-hub`.
- P1 Componentes compartilhados: primeira leva implementada em `lib/widgets/shared/`.
- Próxima etapa recomendada: validar com Flutter instalado e melhorar a árvore de missões.

## P0 — Fundação

### 1. README real — concluído

Substituir o template padrão de Flutter por documentação do app real.

Critérios:

- README explica o jogo.
- README lista comandos reais.
- README menciona dados mockados, áudio/TTS e stack Flutter.

### 2. Teste inicial corrigido — concluído

Corrigir `test/widget_test.dart`, que ainda referencia o app template.

Critérios:

- Teste usa `SpaceMissionArchitectApp`.
- Teste encontra título ou CTA inicial.
- `flutter test` passa ou erro é documentado.

### 3. Documentação de projeto — concluído

Criar:

- `AGENTS.md`
- `docs/UX_AUDIT.md`
- `docs/ARCHITECTURE_AUDIT.md`
- `docs/UX_ROADMAP.md`

Critérios:

- Documentos descrevem estado atual e próximos passos.
- Futuras tarefas do Codex têm regras claras.

## P1 — Fluxo de campanha

### 4. Criar `CampaignHubScreen` — implementado em `ux-campaign-hub`

Inserir uma Central da Campanha entre seleção de agência e árvore de missões.

Critérios:

- Após escolher agência, o jogador vê estado da campanha.
- A tela mostra agência, orçamento, reputação, carreira, objetivo recomendado e rivais.
- CTA principal leva para a árvore de missões.
- Não altera mecânicas.

### 5. Criar componentes compartilhados — primeira leva implementada em `ux-campaign-hub`

Componentes criados:

- `SpacePanel`
- `MetricTile`
- `StatusPill`
- `SectionHeader`
- `EmptyState`
- `PrimaryObjectiveCard`

Critérios:

- Componentes usam `AppTheme`.
- Componentes não contêm regra de jogo.
- `CampaignHubScreen` usa esses componentes.

### 6. Melhorar árvore de missões — próxima etapa recomendada

Tornar o mapa de campanha mais acionável.

Critérios:

- Botão de filtros funciona.
- Missão bloqueada explica causa e solução.
- Requisitos por ID são exibidos como nomes amigáveis.
- Busca por missão/tipo/era é considerada.

## P2 — Planejamento

### 7. Modularizar `MissionPlanningScreen`

Extrair widgets e lógica auxiliar para reduzir densidade.

Candidatos:

- `MissionHeaderCard`
- `PlanningActionDock`
- `BudgetPlannerCard`
- `ChanceRiskCard`
- `TestHistoryBanner`
- `CalibrationWorkbench`
- `SupportModulesSection`

Critérios:

- Comportamento preservado.
- Fórmulas não alteradas.
- Tela fica menor e mais legível.

### 8. Criar stepper de planejamento

Guiar o jogador por:

```text
Ajustar variáveis → Componentes → Equipe → Testes → Prontidão → Lançar
```

Critérios:

- Próximo passo fica claro.
- Bloqueios mostram causa e solução.
- Ação recomendada aparece em destaque.

### 9. Melhorar prontidão de lançamento

Criar resumo claro antes do lançamento.

Critérios:

- Chance, risco, confiança, orçamento e testes ficam visíveis.
- Alertas são compreensíveis.
- Jogador entende consequências antes de confirmar.

## P3 — Controle, relatório e acessibilidade

### 10. Melhorar `MissionTrackingScreen`

Critérios:

- Evento crítico é impossível de ignorar.
- Ação recomendada é clara.
- Controles de pausa/velocidade/aborto são visíveis.
- Log separa evento normal, alerta e crítico.

### 11. Melhorar `MissionReportScreen`

Critérios:

- Relatório vira debriefing didático.
- Explica o que funcionou e o que falhou.
- Mostra impacto no orçamento, reputação, ciência e carreira.
- Recomenda próxima ação.

### 12. Preferências e acessibilidade

Critérios:

- Controle de música, efeitos, voz e narração.
- Opção para reduzir animações/alertas.
- Labels visíveis em pt-BR com acentos.
- Botões importantes com tooltip/Semantics.

## Métricas qualitativas de sucesso

- O jogador sempre sabe o próximo passo.
- Missões bloqueadas explicam como desbloquear.
- Planejamento parece uma jornada, não um painel técnico.
- Eventos críticos comunicam urgência e ação.
- Relatório final ensina a jogar melhor.
- O app preserva a atmosfera audiovisual sem sacrificar clareza.

## Próxima etapa recomendada

Validar a branch `ux-campaign-hub` com `flutter analyze` e `flutter test`. Depois, melhorar a árvore de missões com filtros funcionais e explicações de bloqueio.
