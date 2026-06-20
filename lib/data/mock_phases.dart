import '../models/mission_phase.dart';

final Map<String, List<MissionPhase>> mockMissionPhases = <String, List<MissionPhase>>{
  'experimental_rocket': <MissionPhase>[
    MissionPhase(id: 'countdown', name: 'Contagem regressiva', order: 1, targetAltitude: 0, targetVelocity: 0, durationSeconds: 15, riskFactors: <String>['Ignicao atrasada']),
    MissionPhase(id: 'ignition', name: 'Ignicao', order: 2, targetAltitude: 1, targetVelocity: 1200, durationSeconds: 20, riskFactors: <String>['Falha de motor']),
    MissionPhase(id: 'ascent', name: 'Subida', order: 3, targetAltitude: 80, targetVelocity: 3500, durationSeconds: 35, riskFactors: <String>['Oscilacao estrutural']),
    MissionPhase(id: 'maxq', name: 'Max-Q', order: 4, targetAltitude: 18, targetVelocity: 1700, durationSeconds: 10, riskFactors: <String>['Stress aerodinamico']),
    MissionPhase(id: 'separation', name: 'Separacao', order: 5, targetAltitude: 60, targetVelocity: 2400, durationSeconds: 8, riskFactors: <String>['Separacao parcial']),
    MissionPhase(id: 'insertion', name: 'Insercao orbital', order: 6, targetAltitude: 120, targetVelocity: 7800, durationSeconds: 30, riskFactors: <String>['Velocidade insuficiente']),
    MissionPhase(id: 'initial_ops', name: 'Operacao inicial', order: 7, targetAltitude: 150, targetVelocity: 7900, durationSeconds: 25, riskFactors: <String>['Perda de telemetria']),
  ],
};
