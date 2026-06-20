class MissionLogEntry {
  const MissionLogEntry({
    required this.tSec,
    required this.message,
    this.isCritical = false,
  });

  final int tSec;
  final String message;
  final bool isCritical;
}
