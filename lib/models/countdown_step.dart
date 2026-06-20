enum CountdownType { test, launch }

enum CountdownStatus { idle, preparing, running, paused, completed, cancelled, failed }

enum CountdownStepStatus { pending, running, success, warning, failed }

class CountdownStep {
  const CountdownStep({
    required this.id,
    required this.label,
    required this.triggerAtSecond,
    this.status = CountdownStepStatus.pending,
    this.isWarning = false,
  });

  final String id;
  final String label;
  final int triggerAtSecond;
  final CountdownStepStatus status;
  final bool isWarning;

  CountdownStep copyWith({CountdownStepStatus? status}) {
    return CountdownStep(
      id: id,
      label: label,
      triggerAtSecond: triggerAtSecond,
      status: status ?? this.status,
      isWarning: isWarning,
    );
  }
}

/// System GO/WARNING/NO-GO status shown during launch countdown.
class SystemGoStatus {
  const SystemGoStatus({
    required this.name,
    required this.goState,
  });

  final String name;
  final GoState goState;
}

enum GoState { go, warning, noGo }

/// Steps for test countdowns keyed by TestOption.id
const Map<String, List<CountdownStep>> kTestCountdownSteps = <String, List<CountdownStep>>{
  'engine_test': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Preparando bancada de teste', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Pressurizacao do sistema', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Ignicao controlada', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Leitura de vibracao', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Temperatura e empuxo', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'structural_test': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Fixacao da estrutura', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Aplicacao de carga', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Vibracao simulada', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Medicao de deformacao', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Verificacao de margem', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'stability_test': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Fixacao da estrutura', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Aplicacao de carga lateral', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Vibracao de baixa frequencia', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Medicao de oscilacao', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Verificacao de margem estrutural', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'comm_test': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Ativando transmissor', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Sincronizando antena', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Enviando telemetria', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Testando perda de sinal', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Verificando redundancia', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'trajectory_sim': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Carregando parametros orbitais', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Calculando perfil de subida', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Simulando separacao', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Verificando insercao orbital', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Avaliando margem', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'safety_test': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Verificando valvulas de emergencia', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Teste de pressao diferencial', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Ativando alarme termico', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Verificacao de rotas de fuga', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Consolidando dados de seguranca', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'thermal_test': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Inicializando camaras termicas', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Aplicando carga termica simulada', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Leitura de sensores de temperatura', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Monitorando fluxo de calor', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Verificando dissipacao termica', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'docking_test': <CountdownStep>[
    CountdownStep(id: 's5', label: 'Inicializando simulacao de acoplamento', triggerAtSecond: 0),
    CountdownStep(id: 's4', label: 'Alinhando vetor de aproximacao', triggerAtSecond: 1),
    CountdownStep(id: 's3', label: 'Executando manobra de acoplamento', triggerAtSecond: 2),
    CountdownStep(id: 's2', label: 'Verificando selagem e pressao', triggerAtSecond: 3),
    CountdownStep(id: 's1', label: 'Testando separacao de emergencia', triggerAtSecond: 4),
    CountdownStep(id: 's0', label: 'Registro dos dados', triggerAtSecond: 5),
  ],
  'integrated_test': <CountdownStep>[
    CountdownStep(id: 's8', label: 'Inicializando sistemas', triggerAtSecond: 0),
    CountdownStep(id: 's7', label: 'Verificando propulsao', triggerAtSecond: 1),
    CountdownStep(id: 's6', label: 'Verificando estrutura', triggerAtSecond: 2),
    CountdownStep(id: 's5', label: 'Verificando comunicacao', triggerAtSecond: 3),
    CountdownStep(id: 's4', label: 'Verificando guiagem', triggerAtSecond: 4),
    CountdownStep(id: 's3', label: 'Simulando anomalia', triggerAtSecond: 5),
    CountdownStep(id: 's2', label: 'Validando redundancias', triggerAtSecond: 6),
    CountdownStep(id: 's1', label: 'Consolidando dados', triggerAtSecond: 7),
    CountdownStep(id: 's0', label: 'Registro final', triggerAtSecond: 8),
  ],
};

const List<CountdownStep> kLaunchCountdownSteps = <CountdownStep>[
  CountdownStep(id: 'l10', label: 'Controle de missao em prontidao', triggerAtSecond: 0),
  CountdownStep(id: 'l9', label: 'Energia interna ativada', triggerAtSecond: 1),
  CountdownStep(id: 'l8', label: 'Telemetria sincronizada', triggerAtSecond: 2),
  CountdownStep(id: 'l7', label: 'Guiagem inicializada', triggerAtSecond: 3),
  CountdownStep(id: 'l6', label: 'Pressurizacao dos tanques', triggerAtSecond: 4),
  CountdownStep(id: 'l5', label: 'Zona de seguranca confirmada', triggerAtSecond: 5),
  CountdownStep(id: 'l4', label: 'Sequencia automatica iniciada', triggerAtSecond: 6),
  CountdownStep(id: 'l3', label: 'Ignicao armada', triggerAtSecond: 7),
  CountdownStep(id: 'l2', label: 'Propulsao em prontidao', triggerAtSecond: 8),
  CountdownStep(id: 'l1', label: 'Liberacao final', triggerAtSecond: 9),
  CountdownStep(id: 'l0', label: 'Ignicao e decolagem', triggerAtSecond: 10),
];

/// Result of a completed test sequence.
class TestRunOutcome {
  const TestRunOutcome({
    required this.testId,
    required this.testName,
    required this.passed,
    required this.hasWarning,
    required this.validatedItems,
    required this.findings,
    required this.riskDelta,
    required this.uncertaintyDelta,
    required this.budgetCost,
    required this.description,
  });

  final String testId;
  final String testName;
  final bool passed;
  final bool hasWarning;
  final List<String> validatedItems;
  final List<String> findings;
  final double riskDelta;
  final double uncertaintyDelta;
  final int budgetCost;
  final String description;
}
