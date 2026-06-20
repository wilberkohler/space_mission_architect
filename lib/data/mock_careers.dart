import '../models/player_career.dart';

const List<PlayerCareer> mockCareers = <PlayerCareer>[
  PlayerCareer(
    level: 1,
    title: 'Estagiario',
    experience: 0,
    experienceToNextLevel: 120,
    unlockedResponsibilities: <String>[
      'Missoes tutorial',
      'Ajuste de variaveis basicas',
      'Execucao de testes essenciais',
    ],
    salaryOrInfluenceBonus: 0,
    description: 'Aprende os fundamentos de planejamento e lancamento.',
  ),
  PlayerCareer(
    level: 2,
    title: 'Engenheiro Junior',
    experience: 0,
    experienceToNextLevel: 180,
    unlockedResponsibilities: <String>[
      'Componentes simples',
      'Testes adicionais',
    ],
    salaryOrInfluenceBonus: 0.03,
    description: 'Comeca a assumir pequenas decisoes tecnicas.',
  ),
  PlayerCareer(
    level: 3,
    title: 'Engenheiro de Missao',
    experience: 0,
    experienceToNextLevel: 260,
    unlockedResponsibilities: <String>[
      'Alocacao parcial de equipe',
      'Simulacao de trajetoria',
    ],
    salaryOrInfluenceBonus: 0.06,
    description: 'Coordena a preparacao de sistemas em missao orbital.',
  ),
  PlayerCareer(
    level: 4,
    title: 'Coordenador Tecnico',
    experience: 0,
    experienceToNextLevel: 360,
    unlockedResponsibilities: <String>[
      'Equipe por especialidade',
      'Correcoes pos-teste',
    ],
    salaryOrInfluenceBonus: 0.1,
    description: 'Orquestra subsistemas e decisoes de risco intermediario.',
  ),
  PlayerCareer(
    level: 5,
    title: 'Gerente de Programa',
    experience: 0,
    experienceToNextLevel: 500,
    unlockedResponsibilities: <String>[
      'Gestao de orcamento ampliada',
      'Negociacao de verba emergencial',
    ],
    salaryOrInfluenceBonus: 0.15,
    description: 'Gerencia prioridades estrategicas da campanha.',
  ),
  PlayerCareer(
    level: 6,
    title: 'Diretor de Missao',
    experience: 0,
    experienceToNextLevel: 650,
    unlockedResponsibilities: <String>[
      'Decisoes criticas completas',
      'Missoes tripuladas complexas',
    ],
    salaryOrInfluenceBonus: 0.21,
    description: 'Assume comando total de missao em ambiente critico.',
  ),
  PlayerCareer(
    level: 7,
    title: 'Diretor do Programa Espacial',
    experience: 0,
    experienceToNextLevel: 0,
    unlockedResponsibilities: <String>[
      'Arvore completa',
      'Cooperacao internacional',
      'Estrategia contra rivais',
    ],
    salaryOrInfluenceBonus: 0.3,
    description: 'Lider maximo da campanha espacial.',
  ),
];
