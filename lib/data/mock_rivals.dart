import '../models/rival_agency_state.dart';

const List<RivalAgencyState> mockRivals = <RivalAgencyState>[
  RivalAgencyState(
    agencyId: 'nasa',
    currentEra: 'Lua',
    progress: 82,
    lastMission: 'Gemini Orbital',
    reputationScore: 92,
    likelyNextMission: 'lunar_flyby',
    milestonesAchieved: <String>['Primeiro satelite', 'Primeiro humano em orbita'],
  ),
  RivalAgencyState(
    agencyId: 'urss',
    currentEra: 'Corrida Espacial',
    progress: 79,
    lastMission: 'Vostok Teste',
    reputationScore: 88,
    likelyNextMission: 'human_orbit',
    milestonesAchieved: <String>['Primeiro satelite artificial'],
  ),
  RivalAgencyState(
    agencyId: 'esa',
    currentEra: 'Corrida Espacial',
    progress: 63,
    lastMission: 'Probe X',
    reputationScore: 76,
    likelyNextMission: 'first_satellite',
    milestonesAchieved: <String>['Cooperacao multinacional'],
  ),
  RivalAgencyState(
    agencyId: 'isro',
    currentEra: 'Era Inicial',
    progress: 48,
    lastMission: 'Launch Vehicle Demo',
    reputationScore: 71,
    likelyNextMission: 'experimental_rocket',
    milestonesAchieved: <String>['Custo por lancamento reduzido'],
  ),
];
