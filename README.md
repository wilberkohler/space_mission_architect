# Space Mission Architect

Space Mission Architect é um jogo estratégico e didático de missões espaciais desenvolvido em Flutter/Dart. O jogador assume o comando de uma agência espacial, escolhe missões, planeja recursos, executa testes, acompanha lançamentos e analisa relatórios finais para avançar na campanha.

## Objetivo do jogo

O app combina simulação leve, tomada de decisão e aprendizado histórico/técnico sobre exploração espacial. A experiência atual usa dados mockados locais e uma camada audiovisual com música, efeitos, narração TTS e feedbacks de cockpit.

## Fluxo atual do jogador

```text
Home cinematográfica
→ Seleção de agência
→ Árvore de missões
→ Planejamento da missão
→ Testes / lançamento
→ Acompanhamento da missão
→ Relatório final
→ Rivais / progresso
```

## Fluxo-alvo de UX

```text
Home
→ Agência
→ Central da Campanha
→ Árvore de Missões
→ Briefing
→ Planejamento
→ Testes
→ Prontidão
→ Lançamento
→ Controle de Missão
→ Debriefing
→ Progressão
```

## Stack

- Flutter / Dart
- Material 3
- Dados mockados locais
- Áudio com `audioplayers` e `just_audio`
- Narração com `flutter_tts`
- Tema visual próprio em `lib/theme/app_theme.dart`

## Estrutura principal

```text
lib/
  audio/      # áudio, efeitos, preferências e gerenciador de som
  data/       # dados mockados de missões, agências, testes e rivais
  game/       # controller, engine e calculadoras de orçamento/risco
  models/     # modelos de domínio do jogo
  screens/    # telas principais
  theme/      # tema visual
  utils/      # formatadores e constantes
  widgets/    # componentes reutilizáveis
```

## Como rodar

Instale dependências:

```bash
flutter pub get
```

Execute análise estática:

```bash
flutter analyze
```

Execute testes:

```bash
flutter test
```

Rode o app:

```bash
flutter run
```

## Observações sobre áudio e TTS

A versão atual usa assets locais em `assets/audio/`. Em alguns ambientes, especialmente desktop/Windows, áudio e TTS podem depender de suporte específico da plataforma. O app deve continuar funcionando mesmo se algum recurso sonoro falhar.

## Estado atual

Esta versão ainda é um MVP/protótipo avançado com dados mockados locais e sem backend/persistência. A prioridade de evolução é melhorar a experiência de campanha, modularizar telas densas e preservar a atmosfera audiovisual.

## Próximas melhorias planejadas

- Criar uma Central da Campanha entre seleção de agência e árvore de missões.
- Modularizar `MissionPlanningScreen`.
- Melhorar árvore de missões com filtros e explicações de bloqueio.
- Melhorar prontidão de lançamento.
- Transformar relatório final em debriefing didático.
- Criar preferências de áudio, narração e redução de animações.

## Documentação de evolução

- `AGENTS.md`: regras para futuras alterações com Codex.
- `docs/UX_AUDIT.md`: auditoria inicial de experiência do usuário.
- `docs/ARCHITECTURE_AUDIT.md`: auditoria inicial de arquitetura.
- `docs/UX_ROADMAP.md`: roteiro incremental de melhorias.
- `docs/UX_CHANGELOG.md`: registro das mudanças de UX.
