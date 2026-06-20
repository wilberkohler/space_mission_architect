# UX Audit — Space Mission Architect

## Objetivo

Este documento registra a primeira auditoria de experiência do usuário do Space Mission Architect. O foco é organizar a evolução do app como uma experiência de campanha clara, leve e didática, evitando que o produto cresça como um conjunto de telas desconectadas.

## Fluxo atual do jogador

```text
Home cinematográfica
→ Seleção de agência
→ Árvore de missões
→ Planejamento da missão
→ Testes / lançamento
→ Acompanhamento em tempo real
→ Relatório final
→ Rivais / progresso
```

## Telas atuais mapeadas

- `HomeScreen`: abertura cinematográfica, narração TTS, idioma, música, crawl e entrada na campanha.
- `AgencySelectionScreen`: escolha da agência, descrição, reputação inicial e orçamento base.
- `MissionTreeScreen`: árvore de missões, detalhe da missão selecionada, acesso ao planejamento e rivais.
- `MissionPlanningScreen`: planejamento, variáveis, testes, orçamento, chance, risco, prontidão e lançamento.
- `MissionTrackingScreen`: simulação em tempo real, fases, telemetria, instabilidades, logs e ações críticas.
- `MissionReportScreen`: resultado final, custos, reputação, ciência, desbloqueios e lições aprendidas.
- `RivalsScreen`: ranking resumido dos rivais.

## Pontos fortes de UX

1. Identidade audiovisual forte, com tema de centro de controle, efeitos sonoros, música e TTS.
2. Fluxo de jogo promissor: escolher agência, planejar missão, testar, lançar, acompanhar e revisar resultado.
3. Árvore de missões com representação visual e painel de detalhes.
4. Planejamento com feedback sobre chance, risco, orçamento e testes.
5. Acompanhamento em tempo real com fases, eventos críticos, logs e controles.
6. Relatório final com custos, reputação, ciência, desbloqueios e lições.
7. Tema próprio com tokens de cores, espaçamentos, raios, decoração e estilos.

## Problemas de UX observados

### Falta de Central da Campanha

Após escolher a agência, o jogador vai direto para a árvore de missões. Falta uma tela de hub para explicar o estado da campanha, mostrar progresso, orçamento, carreira, reputação, objetivo principal e próximos passos.

### Próximo passo nem sempre é óbvio

O app tem muitos sinais e painéis, mas nem sempre deixa claro o que o jogador deve fazer agora. A UX deve sempre responder:

```text
Onde estou?
Qual é meu objetivo?
O que devo fazer agora?
Por que algo está bloqueado?
Como destravar?
```

### Telas densas

`MissionPlanningScreen` concentra muitos módulos: ações, testes, variáveis, componentes, equipe, orçamento, risco, bloqueios, modais e launch flow. A tela é funcional, mas precisa ser dividida em componentes menores e em uma jornada visual.

### Linguagem inconsistente

Há textos visíveis em pt-BR sem acentos, como `Missao`, `Orcamento`, `Lancamento`, `Reputacao`, `Comunicacao`, `Seguranca` e `Propulsao`. A correção deve afetar apenas labels visíveis, preservando IDs internos.

### Navegação do cockpit parcialmente incompleta

O scaffold de cockpit mostra abas como Árvore, Planejamento, Missão, Relatórios e Menu. Algumas telas não tratam todas as abas de forma completa, o que pode parecer botão inativo.

### Árvore de missões precisa explicar melhor bloqueios

Missões bloqueadas devem mostrar causa e solução em linguagem de jogador. Requisitos internos por ID devem ser traduzidos para nomes de missões e ações.

### Planejamento precisa virar jornada guiada

O planejamento deve ser organizado como fluxo:

```text
1. Ajustar variáveis
2. Escolher componentes
3. Alocar equipe
4. Rodar testes
5. Revisar prontidão
6. Lançar
```

### Relatório final pode ser mais didático

O relatório deve explicar por que a missão teve sucesso ou falhou, quais decisões impactaram o resultado e qual é a próxima ação recomendada.

### Acessibilidade e preferências

O app usa muitos estímulos visuais e sonoros. Deve haver preferência para volume, narração automática, redução de animações, intensidade de alertas e idioma. Feedbacks importantes não devem depender apenas de cor.

## Riscos de performance e estabilidade

- Telas grandes com muitos cálculos e estados locais podem ficar difíceis de manter.
- `MissionTrackingScreen` usa timer e atualização frequente; deve evitar rebuild completo desnecessário.
- Áudio e TTS devem falhar de forma segura, sem travar o fluxo.
- A árvore de missões pode precisar de otimização se o número de missões crescer.

## Recomendações priorizadas

### P0 — Fundação

- Atualizar README para explicar o app real.
- Corrigir smoke test que ainda referencia app template.
- Criar `AGENTS.md`.
- Criar documentação de UX, arquitetura e roadmap.
- Garantir `flutter analyze` e `flutter test` como rotina.

### P1 — Fluxo de campanha

- Criar `CampaignHubScreen` entre seleção de agência e árvore de missões.
- Criar componentes compartilhados: painel, métrica, status, seção, estado vazio e objetivo principal.
- Tornar o botão de filtro da árvore funcional.
- Melhorar painel de detalhe de missão com causa/solução de bloqueio.

### P2 — Planejamento

- Modularizar `MissionPlanningScreen`.
- Criar stepper visual de planejamento.
- Melhorar mensagens de bloqueio e ações recomendadas.
- Criar resumo de prontidão antes do lançamento.

### P3 — Polimento e acessibilidade

- Melhorar `MissionTrackingScreen` com painel de ação atual e feedback crítico mais claro.
- Melhorar `MissionReportScreen` como debriefing didático.
- Criar preferências de áudio, narração e animação.
- Preparar persistência de campanha, se fizer sentido.

## Próxima etapa recomendada

Criar a `CampaignHubScreen` e componentes compartilhados leves. Essa etapa melhora imediatamente a clareza da campanha sem alterar regras de jogo.
