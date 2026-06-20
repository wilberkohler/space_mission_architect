enum MissionEventType { info, warning, critical, success }

class MissionEvent {
  const MissionEvent({
    required this.id,
    required this.phaseId,
    required this.title,
    required this.description,
    required this.severity,
    required this.options,
    required this.canAbort,
    required this.canTerminateFlight,
    this.tSec = 0,
    this.phaseIndex = 0,
    this.type = MissionEventType.info,
  });

  final String id;
  final String phaseId;
  final String title;
  final String description;
  final String severity;
  final List<String> options;
  final bool canAbort;
  final bool canTerminateFlight;

  // Backward compatibility fields used in current UI runtime.
  final int tSec;
  String get message => '$title: $description';
  final MissionEventType type;
  final int phaseIndex;

  bool get isCritical =>
      type == MissionEventType.critical ||
      severity.toLowerCase() == 'critical';
}
