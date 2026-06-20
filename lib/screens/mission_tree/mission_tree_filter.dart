import '../../models/mission.dart';

enum MissionTreeFilter {
  all('Todas', 'Mostra todos os nós da campanha.'),
  available('Disponíveis', 'Missões prontas para avaliar e planejar.'),
  locked('Bloqueadas', 'Missões com requisitos pendentes.'),
  success('Concluídas', 'Missões finalizadas com sucesso.'),
  partial('Parciais', 'Missões com sucesso parcial.'),
  failure('Falhas', 'Missões finalizadas com falha.');

  const MissionTreeFilter(this.label, this.description);

  final String label;
  final String description;

  bool matches(Mission mission) {
    return switch (this) {
      MissionTreeFilter.all => true,
      MissionTreeFilter.available => mission.status == MissionStatus.available,
      MissionTreeFilter.locked => mission.status == MissionStatus.locked,
      MissionTreeFilter.success => mission.status == MissionStatus.success,
      MissionTreeFilter.partial =>
        mission.status == MissionStatus.partialSuccess,
      MissionTreeFilter.failure => mission.status == MissionStatus.failure,
    };
  }
}
