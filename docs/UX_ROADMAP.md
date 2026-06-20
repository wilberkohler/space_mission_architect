# UX Roadmap

## Princípio

Evoluir o Space Mission Architect em etapas pequenas, revisáveis e testáveis. Cada etapa deve preservar mecânicas, fórmulas, ids mockados, assets de áudio e fluxo existente até que uma mudança específica seja documentada e coberta por teste.

## P0 — Fundação

Objetivo: estabilizar a base antes de novas telas e refatorações maiores.

- Atualizar `README.md` para representar o projeto real.
- Corrigir o teste inicial para renderizar `SpaceMissionArchitectApp`.
- Garantir `flutter pub get`.
- Garantir `flutter analyze`.
- Garantir `flutter test`.
- Criar documentação de auditoria.
- Criar regras de trabalho em `AGENTS.md`.
- Registrar problemas atuais de idioma, navegação, densidade e arquitetura.

Critério de saída: documentação criada, teste smoke executável, comandos informados e nenhuma mecânica alterada.

## P1 — Fluxo de campanha

Objetivo: transformar a navegação em uma campanha mais clara.

- Criar `CampaignHubScreen`. **Concluído em 2026-06-20:** a primeira versão da Central da Campanha foi adicionada entre a seleção de agência e a árvore de missões.
- Melhorar navegação entre Home, Agência, Central da Campanha, Árvore, Planejamento, Relatório e Rivais.
- Melhorar árvore de missões com estado, bloqueios e próximos passos mais didáticos. **Concluído em 2026-06-20:** foram adicionados filtros por status, busca textual, estado vazio e detalhes de bloqueio mais claros.
- Criar componentes compartilhados para cards de campanha, status, ações principais e progresso.
- Definir papel de Rivais dentro do loop de campanha.
- Preservar `MissionTreeScreen` e demais telas existentes durante a transição.

Critério de saída: o jogador entende onde está, qual é o próximo passo e como retornar ao fluxo principal.

## P2 — Planejamento

Objetivo: reduzir densidade da etapa de preparação e tornar decisões mais didáticas.

- Modularizar `MissionPlanningScreen`.
- Criar stepper de planejamento.
- Separar briefing, testes, variáveis, componentes, equipe e prontidão.
- Melhorar mensagens de bloqueio.
- Criar resumo de prontidão para lançamento.
- Extrair view models leves para leitura de estado sem alterar fórmulas.
- Adicionar testes focados para cálculos/estado antes de mover lógica.

Critério de saída: planejamento fica mais legível, com etapas claras, mantendo os mesmos resultados de jogo.

## P3 — Polimento

Objetivo: melhorar clareza, acessibilidade e sensação de campanha contínua.

- Melhorar `MissionTrackingScreen`.
- Melhorar `MissionReportScreen`.
- Melhorar acessibilidade, contraste, semântica e navegação por teclado.
- Melhorar preferências de áudio/animação.
- Corrigir textos visíveis em pt-BR de forma sistemática.
- Preparar persistência de campanha, se fizer sentido depois.
- Revisar performance de telas densas e atualizações em tempo real.

Critério de saída: experiência mais polida, acessível e pronta para expansão de conteúdo.

## Fora do escopo desta etapa

- Implementar `CampaignHubScreen`.
- Refatorar `MissionPlanningScreen`.
- Alterar navegação principal.
- Alterar mecânicas, fórmulas, desbloqueios, XP, risco, reputação ou orçamento.
- Trocar, remover ou adicionar assets de áudio.
- Adicionar dependências.
