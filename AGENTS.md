# AGENTS.md

## Projeto

Space Mission Architect é um app Flutter/Dart de estratégia didática sobre missões espaciais. O jogador escolhe uma agência, avança por uma campanha de missões históricas/ficcionais, planeja recursos, executa testes, acompanha lançamento e voo, recebe um debriefing e observa progresso próprio e de rivais.

O projeto valoriza atmosfera audiovisual, leitura clara de risco/orçamento/reputação e uma experiência guiada por campanha. Mudanças futuras devem preservar esse caráter antes de adicionar novas funcionalidades.

## Comandos principais

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Regras de evolução

- Não alterar mecânicas de jogo, fórmulas de orçamento, risco, reputação, XP, desbloqueios ou resultado de missão sem testes explícitos cobrindo o comportamento antes e depois.
- Não colocar lógica de jogo complexa dentro de Widgets. Regras de domínio devem ficar em controllers, engines, calculators, services ou view models testáveis.
- Preservar áudio, TTS e atmosfera audiovisual. Não remover ou trocar assets de áudio sem uma decisão documentada.
- Manter textos visíveis em pt-BR com acentos corretos. Corrigir inconsistências de idioma ou mojibake quando forem tocadas, sem misturar inglês e português na mesma superfície de UX.
- Preferir componentes reutilizáveis para cartões, painéis, indicadores, navegação, blocos de status e controles recorrentes.
- Não criar telas soltas fora do fluxo de campanha. Toda nova tela deve ter posição clara no fluxo principal e caminho de retorno.
- Atualizar documentação sempre que houver mudança de UX, fluxo, navegação, mecânica percebida pelo jogador ou arquitetura de telas.
- Manter dados mockados com nomes internos e ids estáveis, salvo migração planejada e documentada.
- Evitar refatorações grandes junto de alterações de UX. Separar fundação, navegação, modularização e polimento em etapas revisáveis.

## Fluxo-alvo da campanha

Home → Agência → Central da Campanha → Árvore de Missões → Briefing → Planejamento → Testes → Prontidão → Lançamento → Controle de Missão → Debriefing → Progressão.

## Diretriz para próximas tarefas do Codex

Antes de implementar novas telas ou UX, leia `README.md`, `docs/UX_AUDIT.md`, `docs/ARCHITECTURE_AUDIT.md` e `docs/UX_ROADMAP.md`. Se encontrar problema estrutural novo, documente o diagnóstico antes de alterar código funcional.
