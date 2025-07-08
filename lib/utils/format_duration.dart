// Utility function to format a duration in seconds for timer display.
String formatDuration(int totalSeconds) {
  if (totalSeconds >= 60) {
    final minutes = (totalSeconds ~/ 60).toString();
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  } else if (totalSeconds >= 10) {
    return totalSeconds.toString();
  } else {
    return totalSeconds.toString();
  }
}

// Utility function to format a duration in seconds for summary display as 'Xm Ys'.
String formatDurationVerbose(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes}m ${seconds}s';
} 