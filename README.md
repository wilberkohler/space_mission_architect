# Space Mission Architect

Space Mission Architect é um app Flutter/Dart de estratégia didática sobre missões espaciais. O jogador assume uma agência, escolhe missões, planeja recursos, executa testes, acompanha o lançamento e recebe um relatório final com impactos de custo, reputação, ciência e progresso.

## Objetivo do jogo

O objetivo é ensinar, de forma lúdica, que missões espaciais dependem de trade-offs entre orçamento, risco, reputação, equipe, componentes, testes e decisões durante o voo.

## Fluxo básico do jogador

Home cinematográfica → Seleção de agência → Árvore de missões → Planejamento da missão → Testes e prontidão → Lançamento/controle de missão → Relatório final → Progresso e rivais.

O fluxo-alvo documentado para evolução é:

Home → Agência → Central da Campanha → Árvore de Missões → Briefing → Planejamento → Testes → Prontidão → Lançamento → Controle de Missão → Debriefing → Progressão.

## Stack

- Flutter
- Dart
- Material UI
- Dados mockados locais
- Assets locais de áudio
- `audioplayers`, `just_audio` e `flutter_tts` já configurados no projeto

## Comandos

Instalar dependências:

```bash
flutter pub get
```

Analisar código:

```bash
flutter analyze
```

Rodar testes:

```bash
flutter test
```

Rodar o app:

```bash
flutter run
```

## Dados e assets

A versão atual usa dados mockados em `lib/data` e assets locais em `assets/audio`. Não há backend nem persistência de campanha nesta fase.

## Áudio e TTS

O app usa música ambiente, efeitos de interface, sons de missão e narração por TTS na abertura. A atmosfera audiovisual é parte central da experiência e deve ser preservada em mudanças futuras.

## Próximas melhorias planejadas

- Criar uma Central da Campanha.
- Melhorar a navegação do fluxo principal.
- Tornar a árvore de missões mais didática.
- Modularizar a tela de planejamento.
- Criar um resumo de prontidão para lançamento.
- Polir acompanhamento da missão e relatório final.
- Melhorar acessibilidade e preferências de áudio/animação.
