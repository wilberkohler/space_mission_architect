String formatDuration(int totalSeconds) {
  final int min = totalSeconds ~/ 60;
  final int sec = totalSeconds % 60;
  return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}
