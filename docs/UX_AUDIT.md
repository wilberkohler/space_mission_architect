# UX Audit

## Escopo

Auditoria inicial do Space Mission Architect em 2026-06-20. Esta etapa é diagnóstica: não altera mecânicas, fórmulas, assets, navegação principal ou telas de produto.

## Mapa das telas atuais

- `HomeScreen`: abertura cinematográfica, TTS, música/ambiente, troca de idioma da introdução, configuração de áudio e entrada da campanha.
- `AgencySelectionScreen`: seleção de agência, reputação inicial, orçamento base e áudio contextual no hover/seleção.
- `MissionTreeScreen`: árvore de missões, seleção de missão, painel de detalhes, motivos de bloqueio, acesso ao planejamento e rivais.
- `MissionPlanningScreen`: planejamento, testes, variáveis, componentes, equipe, resumo, prontidão e início do fluxo de lançamento.
- `MissionTrackingScreen`: acompanhamento ao vivo, telemetria, linha do tempo de fases, logs, eventos críticos, estabilidade, aborto/encerramento e conclusão.
- `MissionReportScreen`: relatório final com custos, reputação, ciência, desbloqueios, lições e retorno para árvore/rivais/início.
- `RivalsScreen`: placar de rivais, manchetes e marcos.
- `CareerProgressModal`: progresso de carreira em modal.
- Modais e widgets de fluxo: prontidão de lançamento, contagem de teste, resultado de teste, decisões de missão e configurações de áudio.

## Fluxo atual do jogador

Home cinematográfica → Seleção de agência → Árvore de missões → Planejamento da missão → Testes/prontidão/lançamento → Acompanhamento da missão → Relatório final → Árvore de missões, Rivais ou Início.

O fluxo é funcional e atmosférico, mas ainda não tem uma Central da Campanha explícita. A árvore acumula parte do papel de hub, enquanto relatório e rivais ficam conectados por navegação direta.

## Pontos fortes de UX

- Identidade audiovisual forte, com TTS, música de fundo, efeitos de UI e sons temáticos por contexto.
- Tema visual consistente de centro de controle, com painéis, telemetria, árvore e cartões de status.
- `GameCockpitScaffold` cria uma base comum para telas internas da campanha.
- Boa intenção didática: orçamento, reputação, risco, ciência, componentes, equipe e testes aparecem como dimensões compreensíveis.
- Acompanhamento da missão tem sensação de tempo real, eventos críticos e ações do jogador.
- A árvore de missões já comunica bloqueios e dependências.

## Problemas de UX

- O fluxo de campanha ainda parece uma sequência de telas conectadas manualmente, sem hub que organize estado, próximos passos e progresso.
- Algumas telas têm excesso de informação simultânea, especialmente planejamento e acompanhamento.
- Muitos textos visíveis estão sem acentos ou com mojibake, por exemplo `MissÃ£o`, `Ãrvore`, `RelatÃ³rios`, `Configurar audio`, `Orcamento`, `variaveis`.
- A mistura entre português e inglês aparece em termos como `Stability Balance Control`, `Score` e textos técnicos.
- A navegação inferior mostra abas nem sempre acionáveis; alguns tabs dependem de callbacks parciais.
- O botão de filtros na árvore existe visualmente, mas ainda não executa ação.
- O usuário iniciante pode não entender claramente a ordem ideal entre selecionar teste, ajustar variáveis, revisar orçamento e lançar.

## Telas densas demais

- `HomeScreen`: combina abertura cinematográfica, TTS, seleção de voz, seleção de idioma, fallback de áudio e entrada da campanha.
- `MissionPlanningScreen`: concentra planejamento, seleção de testes, execução de testes, histórico, variáveis, componentes, equipe, cálculo de prontidão, bloqueios de orçamento e navegação para lançamento.
- `MissionTrackingScreen`: concentra simulação temporal, telemetria, logs, eventos críticos, controle de estabilidade, ciência, aborto e transição para relatório.
- `GameController`: não é tela, mas afeta UX porque concentra estado de campanha, seleção, teste, reputação, XP, relatório e desbloqueios.

## Inconsistências de texto/idioma

- Há textos em pt-BR sem acentos: `Missao`, `Orcamento`, `Tecnica`, `Cientifica`, `Publica`, `licoes`, `veiculo`, `variaveis`, `lancamento`.
- Há mojibake em textos visíveis: `MissÃ£o`, `RelatÃ³rio`, `Ãrvore`, `INÃCIO`.
- Há inglês em superfícies de UX: `Start Campaign`, `Space Mission Program`, `Stability Balance Control`, `Score`.
- A Home alterna pt-BR/en-US, mas o restante do app aparenta ser majoritariamente pt-BR.

## Problemas de navegação

- Não existe uma Central da Campanha para consolidar próximo objetivo, status da agência, progresso, missão selecionada e rivais.
- `MissionTreeScreen` funciona como hub improvisado.
- Retornos no relatório usam `push` e `pushAndRemoveUntil` de formas diferentes, o que pode criar pilhas de navegação longas.
- A navegação inferior do cockpit não cobre todos os caminhos e pode sugerir destinos que não estão disponíveis.
- Rivais aparecem como tela lateral, mas ainda sem papel claro no loop de progressão.

## Oportunidades na árvore de missões

- Separar visualmente missões disponíveis, bloqueadas, concluídas, falhas e sucesso parcial com legenda mais didática.
- Tornar motivos de bloqueio mais orientados a ação: "conclua X", "alcance reputação Y", "necessário orçamento Z".
- Adicionar filtros reais por era, tipo, status e complexidade em etapa futura.
- Mostrar melhor o impacto da missão selecionada: recompensas, riscos, pré-requisitos e desbloqueios prováveis.
- Preparar o caminho para um Briefing antes do Planejamento.

## Oportunidades no planejamento

- Transformar a tela em etapas: Briefing → Configuração → Testes → Equipe/Componentes → Prontidão.
- Modularizar painéis em widgets menores e reutilizáveis.
- Melhorar mensagens de bloqueio de lançamento com ações recomendadas.
- Fixar um resumo de prontidão que explique risco, orçamento restante, testes executados e pontos críticos.
- Diferenciar melhor "selecionar teste" de "executar teste".

## Oportunidades no acompanhamento da missão

- Separar simulação/estado ao vivo de UI para facilitar ajustes e testes.
- Reduzir carga cognitiva com prioridades visuais: fase atual, alerta ativo e próxima ação.
- Oferecer preferências de reduzir animação/áudio em etapa futura.
- Explicar melhor consequências de aborto, encerramento e coleta de dados.
- Melhorar logs com categorias e hierarquia visual.

## Oportunidades no relatório final

- Transformar o relatório em debriefing didático: o que deu certo, o que falhou, por quê e próximo passo.
- Destacar progressão de campanha e carreira no fim.
- Mostrar desbloqueios e mudanças na árvore de modo mais explícito.
- Padronizar rotas de saída: voltar à campanha, ver rivais, revisar missão.
- Corrigir acentos e termos para pt-BR.

## Oportunidades de acessibilidade

- Revisar contraste e tamanho de textos pequenos em painéis densos.
- Adicionar labels semânticos em botões icônicos e controles personalizados.
- Criar alternativa para usuários sensíveis a áudio, TTS ou animações intensas.
- Garantir que controles de estabilidade e sliders sejam operáveis por teclado/leitor de tela.
- Evitar depender só de cor para status de sucesso, alerta, bloqueio ou falha.

## Riscos de performance

- `MissionPlanningScreen` tem 1812 linhas e muitos painéis roláveis/listas dentro de containers fixos.
- `MissionTrackingScreen` atualiza estado em tempo real; já usa `ValueNotifier`, mas ainda concentra muita lógica em uma única tela.
- Áudio/TTS e fallbacks por plataforma aumentam risco de travamentos se continuarem acoplados à Home.
- Widgets grandes com cálculos inline podem dificultar otimização fina.
- A árvore e a telemetria podem ficar pesadas conforme o número de missões e eventos crescer.

## Recomendações

### P0

- Atualizar documentação e regras do projeto.
- Corrigir smoke test inicial para renderizar o app real.
- Garantir `flutter pub get`, `flutter analyze` e `flutter test`.
- Registrar problemas de texto/idioma e navegação sem tentar resolver tudo nesta etapa.

### P1

- Criar `CampaignHubScreen` como central de campanha.
- Reorganizar navegação para deixar claro o loop principal.
- Melhorar árvore de missões com filtros reais e bloqueios mais didáticos.
- Consolidar componentes compartilhados para cartões de status, ações e painéis.

### P2

- Modularizar `MissionPlanningScreen`.
- Introduzir stepper de planejamento.
- Criar resumo de prontidão persistente.
- Melhorar mensagens de bloqueio e recuperação de planejamento.

### P3

- Polir `MissionTrackingScreen` e `MissionReportScreen`.
- Corrigir idioma/acessibilidade de forma sistemática.
- Adicionar preferências de áudio/animação.
- Preparar persistência de campanha se o produto evoluir além de dados mockados.
