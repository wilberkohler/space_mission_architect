import '../models/agency.dart';
import '../models/component_option.dart';
import '../models/mission.dart';
import '../models/mission_phase.dart';
import '../models/mission_variable.dart';
import '../models/rival_agency_state.dart';
import '../models/team_specialty.dart';
import '../models/test_option.dart';
import 'mock_agencies.dart';
import 'mock_components.dart';
import 'mock_missions.dart';
import 'mock_phases.dart';
import 'mock_rivals.dart';
import 'mock_tests.dart';

class MockData {
  static final List<Agency> agencies = List<Agency>.from(mockAgencies);

  static final List<Mission> missions = mockMissions
      .map(
        (Mission mission) => mission.copyWith(
          phases: mockMissionPhases[mission.id] ??
              <MissionPhase>[
                MissionPhase(
                  id: 'countdown',
                  name: 'Contagem regressiva',
                  order: 1,
                  targetAltitude: 0,
                  targetVelocity: 0,
                  durationSeconds: 12,
                  riskFactors: <String>['Falha de ignicao'],
                ),
                MissionPhase(
                  id: 'ascent',
                  name: 'Subida',
                  order: 2,
                  targetAltitude: 120,
                  targetVelocity: 7800,
                  durationSeconds: 35,
                  riskFactors: <String>['Instabilidade'],
                ),
                MissionPhase(
                  id: 'insertion',
                  name: 'Insercao orbital',
                  order: 3,
                  targetAltitude: 320,
                  targetVelocity: 27800,
                  durationSeconds: 28,
                  riskFactors: <String>['Velocidade insuficiente'],
                ),
              ],
        ),
      )
      .toList();

  static final List<MissionVariable> missionVariables = <MissionVariable>[
    const MissionVariable(
      id: 'propulsion',
      name: 'Propulsao',
      value: 72,
      min: 0,
      max: 100,
      estimatedIdealMin: 65,
      estimatedIdealMax: 80,
      confidence: 0.65,
      weight: 1.0,
    ),
    const MissionVariable(
      id: 'mass',
      name: 'Massa/Estrutura',
      value: 68,
      min: 0,
      max: 100,
      estimatedIdealMin: 60,
      estimatedIdealMax: 78,
      confidence: 0.62,
      weight: 0.8,
    ),
    const MissionVariable(
      id: 'stability',
      name: 'Estabilidade',
      value: 70,
      min: 0,
      max: 100,
      estimatedIdealMin: 64,
      estimatedIdealMax: 80,
      confidence: 0.6,
      weight: 0.9,
    ),
    const MissionVariable(
      id: 'communication',
      name: 'Comunicacao',
      value: 66,
      min: 0,
      max: 100,
      estimatedIdealMin: 65,
      estimatedIdealMax: 82,
      confidence: 0.58,
      weight: 0.7,
    ),
    const MissionVariable(
      id: 'guidance',
      name: 'Guiagem',
      value: 64,
      min: 0,
      max: 100,
      estimatedIdealMin: 66,
      estimatedIdealMax: 84,
      confidence: 0.56,
      weight: 0.85,
    ),
    const MissionVariable(
      id: 'safety',
      name: 'Seguranca',
      value: 68,
      min: 0,
      max: 100,
      estimatedIdealMin: 70,
      estimatedIdealMax: 90,
      confidence: 0.64,
      weight: 1,
    ),
    const MissionVariable(
      id: 'thermal_control',
      name: 'Controle Termico',
      value: 62,
      min: 0,
      max: 100,
      estimatedIdealMin: 66,
      estimatedIdealMax: 84,
      confidence: 0.55,
      weight: 0.8,
    ),
    const MissionVariable(
      id: 'bio_support',
      name: 'Suporte Biologico',
      value: 60,
      min: 0,
      max: 100,
      estimatedIdealMin: 64,
      estimatedIdealMax: 82,
      confidence: 0.52,
      weight: 0.75,
    ),
    const MissionVariable(
      id: 'life_support',
      name: 'Suporte a Vida',
      value: 58,
      min: 0,
      max: 100,
      estimatedIdealMin: 65,
      estimatedIdealMax: 84,
      confidence: 0.5,
      weight: 0.95,
    ),
    const MissionVariable(
      id: 'reentry',
      name: 'Reentrada',
      value: 61,
      min: 0,
      max: 100,
      estimatedIdealMin: 66,
      estimatedIdealMax: 86,
      confidence: 0.53,
      weight: 0.88,
    ),
    const MissionVariable(
      id: 'energy',
      name: 'Energia',
      value: 65,
      min: 0,
      max: 100,
      estimatedIdealMin: 68,
      estimatedIdealMax: 86,
      confidence: 0.6,
      weight: 0.9,
    ),
    const MissionVariable(
      id: 'docking',
      name: 'Acoplamento',
      value: 57,
      min: 0,
      max: 100,
      estimatedIdealMin: 63,
      estimatedIdealMax: 82,
      confidence: 0.49,
      weight: 0.82,
    ),
  ];

  static final List<ComponentOption> components = List<ComponentOption>.from(mockComponents);

  static final List<TeamSpecialty> defaultTeam = <TeamSpecialty>[
    const TeamSpecialty(
      id: 'technical_general',
      name: 'Tecnica Geral',
      assigned: 4,
      recommended: 5,
      costPerMember: 4,
      affects: <String>['propulsion', 'mass', 'stability'],
    ),
    const TeamSpecialty(
      id: 'communications',
      name: 'Comunicacoes',
      assigned: 2,
      recommended: 3,
      costPerMember: 4,
      affects: <String>['communication', 'guidance'],
    ),
    const TeamSpecialty(
      id: 'safety_ops',
      name: 'Seguranca Operacional',
      assigned: 2,
      recommended: 3,
      costPerMember: 4,
      affects: <String>['safety', 'thermal_control'],
    ),
    const TeamSpecialty(
      id: 'propulsion',
      name: 'Propulsao Avancada',
      assigned: 4,
      recommended: 6,
      costPerMember: 5,
      affects: <String>['propulsion', 'energy'],
    ),
    const TeamSpecialty(
      id: 'structures',
      name: 'Estruturas',
      assigned: 3,
      recommended: 4,
      costPerMember: 4,
      affects: <String>['mass', 'stability'],
    ),
    const TeamSpecialty(
      id: 'guidance',
      name: 'Guiagem',
      assigned: 2,
      recommended: 4,
      costPerMember: 4,
      affects: <String>['guidance', 'reentry'],
    ),
    const TeamSpecialty(
      id: 'bio_support',
      name: 'Suporte Biologico',
      assigned: 2,
      recommended: 3,
      costPerMember: 3,
      affects: <String>['life_support', 'bio_support'],
    ),
    const TeamSpecialty(
      id: 'docking',
      name: 'Acoplamento Orbital',
      assigned: 1,
      recommended: 3,
      costPerMember: 5,
      affects: <String>['docking', 'guidance'],
    ),
  ];

  static final List<TestOption> testOptions = List<TestOption>.from(mockTests);

  static final List<RivalAgencyState> rivals = List<RivalAgencyState>.from(mockRivals);
}
