# Space Mission Architect — Codex Instructions

## Projeto

Space Mission Architect é um app Flutter/Dart de estratégia e aprendizado sobre missões espaciais. O app usa uma experiência audiovisual com tema de centro de controle, seleção de agência, árvore de missões, planejamento, testes, lançamento, acompanhamento em tempo real e relatório final.

## Comandos principais

Use estes comandos antes de concluir mudanças relevantes:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Se algum comando falhar por limitação do ambiente, registre exatamente o erro no resumo final e não esconda a falha.

## Fluxo-alvo de experiência

A evolução de UX deve seguir este fluxo principal:

```text
Home → Agência → Central da Campanha → Árvore de Missões → Briefing → Planejamento → Testes → Prontidão → Lançamento → Controle de Missão → Debriefing → Progressão
```

Evite criar telas soltas fora desse fluxo. Novas telas devem reforçar a campanha, a tomada de decisão e a clareza do próximo passo do jogador.

## Regras críticas

1. Não alterar mecânicas de jogo sem testes e documentação.
2. Não alterar fórmulas de orçamento, risco, reputação, XP, desbloqueio de missões ou resultado de missão sem registrar a mudança e criar validação.
3. Não alterar assets de áudio sem solicitação explícita.
4. Não adicionar dependências sem justificar o motivo e o impacto.
5. Não colocar lógica de jogo complexa diretamente dentro de Widgets.
6. Separar UI, estado de tela, view models/services e engine sempre que possível.
7. Preservar a atmosfera audiovisual do jogo, incluindo áudio, TTS, ambientação e feedbacks de cockpit.
8. Manter textos visíveis em pt-BR com acentos. Não alterar IDs internos apenas para corrigir labels visíveis.
9. Preferir componentes reutilizáveis e consistentes com `lib/theme/app_theme.dart`.
10. Evitar telas muito densas. Quando necessário, dividir por etapa, seção ou componente.
11. Atualizar `docs/UX_CHANGELOG.md` em mudanças futuras de UX.
12. Para alterações estruturais, atualizar ou criar documentação em `docs/`.
13. Manter o app funcionando com dados mockados enquanto não houver backend/persistência.
14. Quando possível, criar testes para smoke, navegação, regras de desbloqueio, orçamento, risco e resultado de missão.

## Padrões de UX

- Toda tela importante deve comunicar: onde estou, qual é meu objetivo e qual é a próxima ação recomendada.
- Estados bloqueados devem explicar causa e solução.
- Feedback visual não deve depender apenas de cor; use texto e ícones.
- Acessibilidade deve ser considerada com `Semantics`, tooltips, contraste e opções para reduzir áudio/animação.
- Áudio e TTS devem falhar de forma segura, sem impedir o jogo.

## Áreas de atenção

- `GameController` concentra muito estado e deve ser dividido gradualmente, sem quebrar mecânicas.
- `HomeScreen` concentra TTS, idioma, narração, música e layout; futura refatoração deve separar serviço de narração.
- `MissionPlanningScreen` concentra layout, testes, orçamento, risco, modais e launch flow; futura refatoração deve extrair widgets e lógica auxiliar.
- `MissionTrackingScreen` deve priorizar clareza de ação durante eventos críticos.
- `MissionReportScreen` deve funcionar como debriefing didático e progressão da campanha.
